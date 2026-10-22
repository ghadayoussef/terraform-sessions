resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "ec2_generated_key" {
  key_name   = var.aws_key_pair_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}


resource "aws_security_group" "nginx_sg" {
  name        = "web-sg"
  description = "Allow HTTP/HTTPS in, all out"
  vpc_id = "vpc-0ab219682ba169f42"
  tags = {
    Name = "nginx-sg"
  }
}

# Ingress: HTTPS from anywhere
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.nginx_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Ingress: SSH from your IP only
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.nginx_sg.id
  cidr_ipv4         = "203.0.113.10/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# # Ingress: allow traffic from another security group (e.g. ALB)
# resource "aws_vpc_security_group_ingress_rule" "http" {
#   security_group_id            = aws_security_group.nginx_sg
#   referenced_security_group_id = aws_security_group.alb.id
#   from_port                    = 80
#   to_port                      = 80
#   ip_protocol                  = "tcp"
# }

# Egress: all outbound
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.nginx_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols; omit from_port/to_port
}

resource "aws_instance" "example" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.micro"

  tags = {
    Name = "example-instance"
  }
}
