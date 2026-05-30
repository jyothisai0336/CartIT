#!/usr/bin/env bash
# SSH tunnel to Jenkins via Bastion
set -euo pipefail

BASTION_IP=$(cd devops/terraform/environments/prod && terraform output -raw bastion_public_ip)
JENKINS_IP=$(cd devops/terraform/environments/prod && terraform output -raw jenkins_private_ip)

echo "🔐 Opening SSH tunnel to Jenkins via Bastion..."
echo "   Bastion: $BASTION_IP"
echo "   Jenkins: $JENKINS_IP"
echo ""
echo "   Jenkins UI will be available at: http://localhost:8080"
echo "   Press Ctrl+C to close tunnel"
echo ""

# Port forward Jenkins through Bastion
ssh -N -L 8080:$JENKINS_IP:8080 \
  -i ~/.ssh/cartit-bastion.pem \
  -o StrictHostKeyChecking=no \
  ec2-user@$BASTION_IP
