#!/usr/bin/env bash
set -euo pipefail
AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🔐 Logging Docker into ECR..."
aws ecr get-login-password --region ${AWS_REGION} \
  | docker login \
      --username AWS \
      --password-stdin \
      ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
echo "✅ Docker authenticated to ECR"
