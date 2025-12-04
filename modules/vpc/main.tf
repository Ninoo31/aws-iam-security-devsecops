data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "secure_vpc"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false # Dynamic IP

  tags = {
    Name = "public-subnet"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-secure-sg"
  description = "Allow SSH from specific IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description     = "Acess to S3 VPC Endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }

  # trivy:ignore:AVD-AWS-0104 - Required for package updates - HTTPS port 443 only
  egress {
    description = "HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # trivy:ignore:AVD-AWS-0104 - Required for package updates - UDP port 53 only
  egress {
    description = "DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # trivy:ignore:AVD-AWS-0104 - Required for package updates - HTTP port 80 only
  egress {
    description = "HTTP for package updates (yum/apt)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-secure-sg"
  }
}

# ═══════════════════════════════════════════════════════════════
# DEFAULT SECURITY GROUP - LOCKED DOWN (Best Practice)
# ═══════════════════════════════════════════════════════════════

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # ✅ NO ingress rules = block all inbound traffic
  # ✅ NO egress rules = block all outbound traffic

  # Force developers to create explicit security groups
  # instead of relying on permissive defaults

  tags = {
    Name        = "default-sg-locked-down"
    Description = "DO NOT USE - Default SG with all traffic blocked"
    Managed     = "Terraform"
  }
}

# ═══════════════════════════════════════════════════════════════
# VPC FLOW LOGS - Network Traffic Monitoring
# ═══════════════════════════════════════════════════════════════

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${aws_vpc.main.id}"
  retention_in_days = 365 # CKV_AWS_338

  tags = {
    Name        = "vpc-flow-logs"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = var.vpc_flow_role
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

  tags = {
    Name        = "vpc-flow-log-all-traffic"
    Description = "Captures all network traffic for security monitoring"
    ManagedBy   = "Terraform"
  }
}