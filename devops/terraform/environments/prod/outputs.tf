output "ecr_repository_url"    { value = module.ecr.repository_url }
output "eks_cluster_name"      { value = module.eks.cluster_name }
output "eks_cluster_endpoint"  { value = module.eks.cluster_endpoint; sensitive = true }
output "bastion_public_ip"     { value = module.bastion.bastion_public_ip }
output "bastion_ssh_command"   { value = module.bastion.ssh_command }
output "jenkins_private_ip"    { value = module.jenkins.jenkins_private_ip }
output "jenkins_url"           { value = module.jenkins.jenkins_url }
output "sonarqube_private_ip"  { value = module.sonarqube.sonarqube_private_ip }
output "sonarqube_url"         { value = module.sonarqube.sonarqube_url }
