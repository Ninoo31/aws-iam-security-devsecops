# KMS Key for S3 Bucket Encryption
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7    # Retain key for 7 days after deletion request
  enable_key_rotation     = true # Enable automatic key rotation

  tags = {
    Name    = "s3-encryption-key"
    Purpose = "S3 bucket encryption"
  }
}

# KMS Key Alias
resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/s3-bucket-encryption"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

# KMS Key Policy to allow S3 to use the key for encryption
resource "aws_kms_key_policy" "s3_encryption_key_policy" {
  key_id = aws_kms_key.s3_encryption_key.key_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key for EC2 instances"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_s3_access.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}