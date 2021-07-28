########### SSM Parameter "inputs"

data "aws_ssm_parameter" "db_user" {
  name = "TAGIOALISI_DB_USER"
}

########### SSM Parameter "outputs"

resource "aws_ssm_parameter" "bot_public_host" {
  type       = "String"
  name       = format("TAGIOALISI_BOT_PUBLIC_HOST_%s", var.stack_suffix)
  value      = aws_instance.bot.public_dns
  depends_on = [aws_instance.bot]
}

resource "aws_ssm_parameter" "bot_private_host" {
  type       = "String"
  name       = format("TAGIOALISI_BOT_PRIVATE_HOST_%s", var.stack_suffix)
  value      = aws_instance.bot.private_dns
  depends_on = [aws_instance.bot]
}

resource "aws_ssm_parameter" "db_host" {
  type  = "String"
  name  = format("TAGIOALISI_DB_HOST_%s", var.stack_suffix)
  value = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "db_port" {
  type  = "String"
  name  = format("TAGIOALISI_DB_PORT_%s", var.stack_suffix)
  value = aws_db_instance.main.port
}

resource "aws_ssm_parameter" "db_username" {
  type  = "String"
  name  = format("TAGIOALISI_DB_USERNAME_%s", var.stack_suffix)
  value = aws_db_instance.main.username
}

resource "aws_ssm_parameter" "db_password" {
  type  = "SecureString"
  name  = format("TAGIOALISI_DB_PASSWORD_%s", var.stack_suffix)
  value = aws_db_instance.main.password
}

