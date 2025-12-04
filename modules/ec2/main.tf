data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name
  tags = {
    Purpose = "IAM Role testing"
  }
}

resource "aws_sns_topic" "bucket_notifications" {
  name = "test_bucket-notification"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.test_bucket.id
  
  topic {
    topic_arn     = aws_sns_topic.bucket_notifications.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure" {
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.test_bucket.id
  key     = "test-file.txt"
  content = "Hello from secure IAM! If you can read this, your role works perfectly."
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = "lab-key" # Ensure you have created this key pair and sent it to your lab environment 
  monitoring             = true
  ebs_optimized          = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Force IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8

    tags = {
      Name = "iam-test-instance-root-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              EOF

  tags = {
    Name = "iam-test-instance"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app.id
  vpc      = true

  tags = {
    Name = "AppInstanceEIP"
  }

  depends_on = [aws_instance.app]
}

resource "aws_instance" "app2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_write_only_name
  key_name               = "lab-key" # Ensure you have created this key pair and sent it to your lab environment 
  monitoring             = true
  ebs_optimized          = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Force IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8

    tags = {
      Name = "iam-test-instance-2-root-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              EOF

  tags = {
    Name = "iam-test-instance"
  }
}

resource "aws_eip" "app_eip2" {
  instance = aws_instance.app2.id
  vpc      = true

  tags = {
    Name = "AppInstanceEIP"
  }
  depends_on = [aws_instance.app]
}