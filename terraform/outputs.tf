output "public_ip" {
  value = aws_instance.web.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/devops-new-key.pem ubuntu@${aws_instance.web.public_ip}"
}
