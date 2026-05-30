# ─── CartIt Bastion Host ───────────────────────────────────────────────────────
# SSH gateway into private subnet — only way to reach Jenkins/SonarQube

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name";                values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.env}-bastion-sg"
  description = "CartIt Bastion Host — SSH gateway"
  vpc_id      = var.vpc_id

  # SSH — only from your office/home IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH from allowed IPs only"
  }

  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-bastion-sg" })
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project}-${var.env}-bastion-key"
  public_key = var.bastion_public_key
  tags       = var.tags
}

# Elastic IP — fixed public IP for Bastion
resource "aws_eip" "bastion" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.project}-${var.env}-bastion-eip" })
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"     # tiny — just for SSH tunneling
  subnet_id                   = var.public_subnet_id   # public subnet — has internet
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    # Bastion hardening
    dnf update -y

    # Disable password auth — key only
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

    # Restrict SSH to ec2-user only
    echo "AllowUsers ec2-user" >> /etc/ssh/sshd_config

    systemctl restart sshd

    # Install session manager (alternative to SSH)
    dnf install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  USERDATA
  )

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-bastion"
    Role = "bastion"
  })

  lifecycle { ignore_changes = [ami] }
}

# Attach Elastic IP to Bastion
resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
