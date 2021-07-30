########### SSM Parameter "inputs"

data "aws_ssm_parameter" "db_user" {
  name = "/tagioalisi/default_db_user"
}

########### SSM Parameter "outputs"

resource "aws_ssm_parameter" "bot_public_host" {
  type       = "String"
  name       = format("/tagioalisi/%s/bot/public_host", lower(var.stack_id))
  value      = aws_instance.bot.public_dns
  depends_on = [aws_instance.bot]
}

resource "aws_ssm_parameter" "bot_private_host" {
  type       = "String"
  name       = format("/tagioalisi/%s/bot/private_host", lower(var.stack_id))
  value      = aws_instance.bot.private_dns
  depends_on = [aws_instance.bot]
}

resource "aws_ssm_parameter" "db_host" {
  type  = "String"
  name       = format("/tagioalisi/%s/db/host", lower(var.stack_id))
  value = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "db_port" {
  type  = "String"
  name       = format("/tagioalisi/%s/db/port", lower(var.stack_id))
  value = aws_db_instance.main.port
}

resource "aws_ssm_parameter" "db_username" {
  type  = "String"
  name       = format("/tagioalisi/%s/db/username", lower(var.stack_id))
  value = aws_db_instance.main.username
}

resource "aws_ssm_parameter" "db_password" {
  type  = "SecureString"
  name       = format("/tagioalisi/%s/db/password", lower(var.stack_id))
  value = aws_db_instance.main.password
}

