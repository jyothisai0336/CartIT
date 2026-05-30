#!/usr/bin/env bash
# SSH tunnel to SonarQube via Bastion
set -euo pipefail

BASTION_IP=$(cd devops/terraform/environments/prod && terraform output -raw bastion_public_ip)
SONAR_IP=$(cd devops/terraform/environments/prod && terraform output -raw sonarqube_private_ip)

echo "🔐 Opening SSH tunnel to SonarQube via Bastion..."
echo "   SonarQube UI will be available at: http://localhost:9000"
echo "   Default login: admin / admin (change on first login)"
echo ""

ssh -N -L 9000:$SONAR_IP:9000 \
  -i ~/.ssh/cartit-bastion.pem \
  -o StrictHostKeyChecking=no \
  ec2-user@$BASTION_IP
