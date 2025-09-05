output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.tomcat.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.tomcat.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.tomcat.public_dns
}

output "tomcat_url" {
  description = "URL to access Tomcat"
  value       = "http://${aws_eip.tomcat.public_ip}:8080"
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i your-private-key.pem ec2-user@${aws_eip.tomcat.public_ip}"
}
