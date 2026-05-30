output "sonarqube_private_ip"  { value = aws_instance.sonarqube.private_ip }
output "sonarqube_instance_id" { value = aws_instance.sonarqube.id }
output "sonarqube_sg_id"       { value = aws_security_group.sonarqube.id }
output "sonarqube_url"         { value = "http://${aws_instance.sonarqube.private_ip}:9000" }
