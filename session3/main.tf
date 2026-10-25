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
  vpc_id      = "vpc-0ab219682ba169f42"
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
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# # Ingress: allow traffic from another security group (e.g. ALB)
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id            = aws_security_group.nginx_sg.id
  cidr_ipv4                    = "0.0.0.0/0"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Egress: all outbound
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.nginx_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols; omit from_port/to_port
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  subnet_id                   = "subnet-08cdad9e5e8ee438a"
  user_data                   = file("${path.module}/init.sh")
  key_name                    = aws_key_pair.ec2_generated_key.key_name
  tags = {
    Name = "example-instance"
  }
}
