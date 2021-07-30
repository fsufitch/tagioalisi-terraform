### Configuration for the web interface runtime

resource "aws_s3_bucket" "web" {
  bucket        = format("tagioalisi-%s-web", lower(var.stack_id))
  acl           = "public-read"
  force_destroy = true

  # TODO: allow pipeline service role write access

  website {
    index_document = "index.html"
    error_document = "index.html" # hm...
  }

}

# TODO: cloudfront distribution? cert? HTTPS?
