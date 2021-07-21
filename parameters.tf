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
