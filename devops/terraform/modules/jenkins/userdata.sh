#!/bin/bash
# CartIt Jenkins Server Bootstrap Script
# Runs automatically on first EC2 boot

set -euo pipefail
exec > >(tee /var/log/cartit-bootstrap.log) 2>&1

echo "=========================================="
echo " CartIt Jenkins Bootstrap Starting"
echo " Project: ${project} | Env: ${env}"
echo "=========================================="

# ── Update system ──────────────────────────────────────────────────────────────
dnf update -y
dnf install -y git curl wget unzip tar jq

# ── Mount Jenkins EBS volume ───────────────────────────────────────────────────
# Format if new volume
if ! blkid /dev/xvdf; then
  mkfs.ext4 /dev/xvdf
fi
mkdir -p /var/lib/jenkins
mount /dev/xvdf /var/lib/jenkins
# Persist mount across reboots
echo "/dev/xvdf /var/lib/jenkins ext4 defaults,nofail 0 2" >> /etc/fstab

# ── Install Java 17 (Jenkins requires Java) ───────────────────────────────────
dnf install -y java-17-amazon-corretto
java -version

# ── Install Jenkins ───────────────────────────────────────────────────────────
wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# ── Install Docker ─────────────────────────────────────────────────────────────
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker jenkins    # Jenkins can run Docker
usermod -aG docker ec2-user

# ── Install AWS CLI v2 ─────────────────────────────────────────────────────────
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
aws --version

# ── Install kubectl ────────────────────────────────────────────────────────────
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
curl -Lo /tmp/kubectl \
  "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
kubectl version --client

# ── Install kustomize ──────────────────────────────────────────────────────────
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" \
  | bash
mv kustomize /usr/local/bin/
kustomize version

# ── Install Trivy ──────────────────────────────────────────────────────────────
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin
trivy --version

# ── Install SonarQube Scanner ──────────────────────────────────────────────────
SONAR_VERSION="5.0.1.3006"
curl -Lo /tmp/sonar-scanner.zip \
  "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$${SONAR_VERSION}-linux.zip"
unzip -q /tmp/sonar-scanner.zip -d /opt
ln -s /opt/sonar-scanner-$${SONAR_VERSION}-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner
sonar-scanner --version

# ── Configure kubectl for EKS ──────────────────────────────────────────────────
# Run as Jenkins user
sudo -u jenkins aws eks update-kubeconfig \
  --name ${eks_cluster} \
  --region ${aws_region} || true

# ── Configure CloudWatch agent ─────────────────────────────────────────────────
dnf install -y amazon-cloudwatch-agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name": "/cartit/${env}/jenkins",
            "log_stream_name": "{instance_id}/jenkins"
          },
          {
            "file_path": "/var/log/cartit-bootstrap.log",
            "log_group_name": "/cartit/${env}/jenkins",
            "log_stream_name": "{instance_id}/bootstrap"
          }
        ]
      }
    }
  }
}
CWCONFIG
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# ── Set correct ownership ──────────────────────────────────────────────────────
chown -R jenkins:jenkins /var/lib/jenkins

# ── Print initial admin password ───────────────────────────────────────────────
echo "=========================================="
echo " Bootstrap Complete!"
echo " Jenkins Initial Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "(Jenkins still starting...)"
echo " Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8080"
echo "=========================================="
