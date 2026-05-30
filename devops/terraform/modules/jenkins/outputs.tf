output "jenkins_private_ip"  { value = aws_instance.jenkins.private_ip }
output "jenkins_instance_id" { value = aws_instance.jenkins.id }
output "jenkins_sg_id"       { value = aws_security_group.jenkins.id }
output "jenkins_role_arn"    { value = aws_iam_role.jenkins.arn }
output "jenkins_url"         { value = "http://${aws_instance.jenkins.private_ip}:8080" }
