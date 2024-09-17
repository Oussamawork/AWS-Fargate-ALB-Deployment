# ecr repo 
resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_repo_name
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.ecr_repo.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:PutImage"
        ]
      }
    ]
  })
}
