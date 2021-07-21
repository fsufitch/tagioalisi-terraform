resource "aws_security_group" "bot" {
  name        = "Tagioalisi Bot SG"
  description = "Rules for managing the traffic of Tagioalisi"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow pinging"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "All outbound traffic OK"
  }
}

resource "aws_instance" "bot" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.bot.id,
  ]

  tags = {
    Name = "Tagioalisi Bot Instance"
  }
}