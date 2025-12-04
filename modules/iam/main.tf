data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_access" {
  name               = "ec2-s3-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Purpose = "Allow EC2 to read S3 securely"
  }
}

# Modify this policy if you want to restrict or expand permissions for the EC2 role
data "aws_iam_policy_document" "s3_readandwrite" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
    resources = [aws_kms_key.s3_encryption_key.arn]
  }
}

resource "aws_iam_role_policy" "s3_readandwrite_policy" {
  name   = "s3-readonly-policy"
  policy = data.aws_iam_policy_document.s3_readandwrite.json
  role   = aws_iam_role.ec2_s3_access.id
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-readonly-profile"
  role = aws_iam_role.ec2_s3_access.name
}

# Other roles and policies for an other instance
resource "aws_iam_role" "ec2_s3_access_write_only" {
  name               = "ec2-s3-writeonly-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Purpose = "Allow EC2 to write S3 securely"
  }
}

# Modify this policy if you want to restrict or expand permissions for the EC2 role
data "aws_iam_policy_document" "s3_writeonly" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
    resources = [aws_kms_key.s3_encryption_key.arn]
  }
}

resource "aws_iam_role_policy" "s3_write_only_policy" {
  name   = "s3-writeonly-policy"
  policy = data.aws_iam_policy_document.s3_writeonly.json
  role   = aws_iam_role.ec2_s3_access_write_only.id
}

resource "aws_iam_instance_profile" "ec2_write_only_profile" {
  name = "ec2-s3-writedonly-profile"
  role = aws_iam_role.ec2_s3_access_write_only.name
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowVPCFlowLogsAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "vpc-flow-logs-role"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "vpc-flow-logs-cloudwatch-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${var.aws_cloudwatch_log_group_arn}:*"
      }
    ]
  })
}