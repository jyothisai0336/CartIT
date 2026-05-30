# ─── CartIt Jenkins EC2 Server ─────────────────────────────────────────────────
# Dedicated EC2 for CI/CD — outside EKS, has full access to ECR + EKS

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group — Jenkins EC2
resource "aws_security_group" "jenkins" {
  name        = "${var.project}-${var.env}-jenkins-sg"
  description = "CartIt Jenkins server security group"
  vpc_id      = var.vpc_id

  # SSH — only from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
    description     = "SSH from Bastion only"
  }

  # Jenkins UI — port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Jenkins Web UI"
  }

  # Jenkins agent port (if using distributed agents)
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Jenkins agent communication"
  }

  # All outbound — Jenkins needs to reach GitHub, ECR, EKS, SonarQube
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-jenkins-sg" })
}

# IAM Role — Jenkins needs to push to ECR and deploy to EKS
resource "aws_iam_role" "jenkins" {
  name = "${var.project}-${var.env}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# Jenkins IAM Policy — least privilege
resource "aws_iam_role_policy" "jenkins" {
  name = "${var.project}-${var.env}-jenkins-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR — push and pull images
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      # EKS — update kubeconfig and deploy
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      },
      # S3 — for build artifacts
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::${var.project}-*", "arn:aws:s3:::${var.project}-*/*"]
      },
      # CloudFront — cache invalidation after deploy
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetDistribution"]
        Resource = "*"
      },
      # Secrets Manager — read secrets for deployment
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project}/*"
      },
      # CloudWatch — push build metrics and logs
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "cloudwatch:PutMetricData"]
        Resource = "*"
      }
    ]
  })
}

# Instance Profile — attaches IAM role to EC2
resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project}-${var.env}-jenkins-profile"
  role = aws_iam_role.jenkins.name
  tags = var.tags
}

# Key Pair — for SSH access via Bastion
resource "aws_key_pair" "jenkins" {
  key_name   = "${var.project}-${var.env}-jenkins-key"
  public_key = var.jenkins_public_key
  tags       = var.tags
}

# EBS Volume — Jenkins home directory (persistent, separate from root)
resource "aws_ebs_volume" "jenkins_home" {
  availability_zone = "${var.aws_region}a"
  size              = 100    # 100GB for builds, workspaces, artifacts
  type              = "gp3"
  encrypted         = true
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-jenkins-home"
  })
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id   # private subnet — no direct internet
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name
  key_name               = aws_key_pair.jenkins.key_name

  # Root volume — encrypted
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  # IMDSv2 enforced — security best practice
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # User data — bootstrap script runs on first boot
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    project     = var.project
    env         = var.env
    aws_region  = var.aws_region
    eks_cluster = var.eks_cluster_name
  }))

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-jenkins"
    Role = "ci-cd"
  })

  lifecycle {
    ignore_changes = [ami, user_data]  # don't replace on AMI update
  }
}

# Attach separate EBS volume for Jenkins home
resource "aws_volume_attachment" "jenkins_home" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.jenkins_home.id
  instance_id = aws_instance.jenkins.id
}

# CloudWatch Log Group for Jenkins logs
resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/cartit/${var.env}/jenkins"
  retention_in_days = 30
  tags              = var.tags
}

# CloudWatch Alarm — Jenkins CPU high
resource "aws_cloudwatch_metric_alarm" "jenkins_cpu" {
  alarm_name          = "${var.project}-${var.env}-jenkins-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Jenkins CPU above 80%"
  dimensions          = { InstanceId = aws_instance.jenkins.id }
  tags                = var.tags
}
