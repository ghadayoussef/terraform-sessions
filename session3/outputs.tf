output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

output "nginx_url" {
  value = "http://${aws_instance.example.public_ip}"
}

output "ssh_command" {
  value = "ssh -i ec2-key.pem ubuntu@${aws_instance.example.public_ip}"
}