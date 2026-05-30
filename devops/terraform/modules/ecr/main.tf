resource "aws_ecr_repository" "cartit" {
  name                 = "${var.project}-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
  tags = var.tags
}
resource "aws_ecr_lifecycle_policy" "cartit" {
  repository = aws_ecr_repository.cartit.name
  policy = jsonencode({ rules=[{ rulePriority=1; description="Keep last 20"; selection={ tagStatus="any"; countType="imageCountMoreThan"; countNumber=20 }; action={ type="expire" } }] })
}
