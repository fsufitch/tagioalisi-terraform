### CodeBuild + CodePipeline for building/deploying the web UI

resource "aws_codepipeline" "web" {
  name     = format("Tagioalisi-Web__%s", var.stack_suffix)
  role_arn = aws_iam_role.web_ci.arn

  artifact_store {
    location = aws_s3_bucket.web_ci.bucket
    type     = "S3"

    # optional: encryption key?
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.fsufitch_github.arn
        FullRepositoryId = "fsufitch/tagioalisi-web"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = format("Tagioalisi-Web__%s", var.stack_suffix)
      }
    }
  }

  stage {
    name = "Deploy-S3-Website"

    action {
      name            = "Deploy-S3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = aws_s3_bucket.web.id
        Extract    = true
      }
    }
  }
}

resource "aws_codebuild_project" "web" {
  name          = format("Tagioalisi-Web__%s", var.stack_suffix)
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.web_ci.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = format("%s/build_cache", aws_s3_bucket.web_ci.id)
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = format("%s/build_logs", aws_s3_bucket.web_ci.id)
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = "master"

  # vpc_config {
  #   vpc_id = aws_vpc.main.id

  #   subnets = [
  #     aws_subnet.example1.id,
  #     aws_subnet.example2.id,
  #   ]

  #   security_group_ids = [
  #     aws_security_group.example1.id,
  #     aws_security_group.example2.id,
  #   ]
  # }
}

resource "aws_s3_bucket" "web_ci" {
  bucket = format("tagioalisi-web-codepipeline--%s", lower(var.stack_suffix))
  acl    = "private"
}

resource "aws_iam_role" "web_ci" {
  name = format("Tagioalisi-Web-CI__%s", var.stack_suffix)
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = format("Tagioalisi-Web-CI-Policy__%s", var.stack_suffix)
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        ## CodePipeline permissions
        {
          Action = ["s3:*"]
          Effect = "Allow"
          Resource = [
            aws_s3_bucket.web_ci.arn,
            "${aws_s3_bucket.web_ci.arn}/*",
            aws_s3_bucket.web.arn,
            "${aws_s3_bucket.web.arn}/*",
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codestar-connections:UseConnection"
          ],
          "Resource" : "${data.aws_codestarconnections_connection.fsufitch_github.arn}"
        },
        ## CodeBuild permissions
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Resource" : [
            "*"
          ],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterfacePermission"
          ],
          "Resource" : [
            "arn:aws:ec2:${var.aws_region}:${var.aws_account}:network-interface/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:AuthorizedService" : "codebuild.amazonaws.com"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*"
          ],
          "Resource" : [
            "${aws_s3_bucket.web_ci.arn}",
            "${aws_s3_bucket.web_ci.arn}/*"
          ]
        }
      ]
    })
  }
}
