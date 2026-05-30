output "bastion_public_ip"  { value = aws_eip.bastion.public_ip }
output "bastion_sg_id"      { value = aws_security_group.bastion.id }
output "bastion_instance_id"{ value = aws_instance.bastion.id }
output "ssh_command"        { value = "ssh -i ~/.ssh/cartit-bastion.pem ec2-user@${aws_eip.bastion.public_ip}" }
