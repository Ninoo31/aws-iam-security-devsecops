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
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
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
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
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