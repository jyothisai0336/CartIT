# ─── CartIt SonarQube EC2 Server ───────────────────────────────────────────────

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name";                values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_security_group" "sonarqube" {
  name        = "${var.project}-${var.env}-sonarqube-sg"
  description = "CartIt SonarQube server"
  vpc_id      = var.vpc_id

  # SSH from Bastion only
  ingress {
    from_port       = 22; to_port = 22; protocol = "tcp"
    security_groups = [var.bastion_sg_id]
    description     = "SSH from Bastion"
  }

  # SonarQube UI — from Jenkins only
  ingress {
    from_port       = 9000; to_port = 9000; protocol = "tcp"
    security_groups = [var.jenkins_sg_id]
    description     = "SonarQube UI from Jenkins"
  }

  egress {
    from_port = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-sonarqube-sg" })
}

resource "aws_key_pair" "sonarqube" {
  key_name   = "${var.project}-${var.env}-sonarqube-key"
  public_key = var.sonarqube_public_key
  tags       = var.tags
}

# SonarQube data volume — 50GB for analysis data
resource "aws_ebs_volume" "sonarqube_data" {
  availability_zone = "${var.aws_region}a"
  size              = 50
  type              = "gp3"
  encrypted         = true
  kms_key_id        = var.kms_key_arn
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-sonarqube-data" })
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type   # t3.medium minimum (needs 3GB RAM)
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  key_name               = aws_key_pair.sonarqube.key_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -euo pipefail
    exec > >(tee /var/log/sonarqube-bootstrap.log) 2>&1

    echo "=== CartIt SonarQube Bootstrap ==="

    # System requirements for SonarQube
    dnf update -y
    dnf install -y java-17-amazon-corretto docker unzip

    # SonarQube kernel requirements
    sysctl -w vm.max_map_count=524288
    sysctl -w fs.file-max=131072
    echo "vm.max_map_count=524288" >> /etc/sysctl.conf
    echo "fs.file-max=131072"       >> /etc/sysctl.conf

    # Mount data volume
    if ! blkid /dev/xvdf; then mkfs.ext4 /dev/xvdf; fi
    mkdir -p /opt/sonarqube-data
    mount /dev/xvdf /opt/sonarqube-data
    echo "/dev/xvdf /opt/sonarqube-data ext4 defaults,nofail 0 2" >> /etc/fstab

    # Install and start Docker
    systemctl enable docker && systemctl start docker

    # Run SonarQube in Docker
    docker run -d \
      --name sonarqube \
      --restart unless-stopped \
      -p 9000:9000 \
      -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
      -v /opt/sonarqube-data/data:/opt/sonarqube/data \
      -v /opt/sonarqube-data/logs:/opt/sonarqube/logs \
      -v /opt/sonarqube-data/extensions:/opt/sonarqube/extensions \
      sonarqube:10-community

    echo "=== SonarQube Bootstrap Complete ==="
    echo "Access at: http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):9000"
    echo "Default login: admin / admin (change immediately)"
  USERDATA
  )

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-sonarqube"
    Role = "code-quality"
  })

  lifecycle { ignore_changes = [ami, user_data] }
}

resource "aws_volume_attachment" "sonarqube_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.sonarqube_data.id
  instance_id = aws_instance.sonarqube.id
}
