# ECS cluster
resource "aws_ecs_cluster" "this" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.this.arn
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.this.name
      }
    }
  }
}

# ECS cluster capacity providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# logging configuration
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/cluster/${var.name}"
  retention_in_days = var.cloud_watch_log_retention_in_days
}

# kms key
resource "aws_kms_key" "this" {
  description = "KMS key for ECS cluster ${var.name}"
}


# kms key policy
resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Id = "ECSClusterFargatePolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" : "*"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow generate data key access for Fargate tasks."
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKeyWithoutPlaintext"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [
              data.aws_caller_identity.current.account_id
            ]
            "kms:EncryptionContext:aws:ecs:clusterName" = [
              "example"
            ]
          }
        }
        Resource = "*"
      },
      {
        Sid    = "Allow grant creation permission for Fargate tasks."
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:CreateGrant"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [
              data.aws_caller_identity.current.account_id
            ]
            "kms:EncryptionContext:aws:ecs:clusterName" = [
              "example"
            ]
          }
          "ForAllValues:StringEquals" = {
            "kms:GrantOperations" = [
              "Decrypt"
            ]
          }
        }
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}