# ═══════════════════════════════════════════════════════════════
# INSTANCE 1 - Read-only S3 Access
# ═══════════════════════════════════════════════════════════════

output "instance_readonly_public_ip" {
  description = "Public IP (Elastic IP) of the read-only instance"
  value       = module.ec2.instance_public_ip
}

output "instance_readonly_id" {
  description = "ID of the read-only instance"
  value       = module.ec2.instance_id
}

output "ssh_command_readonly" {
  description = "SSH command for read-only instance"
  value       = "ssh -i ~/.ssh/aws-lab-key ec2-user@${module.ec2.instance_public_ip}"
}

# ═══════════════════════════════════════════════════════════════
# INSTANCE 2 - Write-only S3 Access
# ═══════════════════════════════════════════════════════════════

output "instance_writeonly_public_ip" {
  description = "Public IP (Elastic IP) of the write-only instance"
  value       = module.ec2.instance2_public_ip
}

output "instance_writeonly_id" {
  description = "ID of the write-only instance"
  value       = module.ec2.instance2_id
}

output "ssh_command_writeonly" {
  description = "SSH command for write-only instance"
  value       = "ssh -i ~/.ssh/aws-lab-key ec2-user@${module.ec2.instance2_public_ip}"
}

# ═══════════════════════════════════════════════════════════════
# S3 BUCKET
# ═══════════════════════════════════════════════════════════════

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.ec2.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.ec2.bucket_arn
}

# ═══════════════════════════════════════════════════════════════
# NETWORK INFO
# ═══════════════════════════════════════════════════════════════

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.vpc.security_group_id
}

# ═══════════════════════════════════════════════════════════════
# QUICK REFERENCE
# ═══════════════════════════════════════════════════════════════

output "quick_reference" {
  description = "Quick reference for testing"
  value       = <<-EOT
  
  ╔════════════════════════════════════════════════════════════════╗
  ║                    INFRASTRUCTURE SUMMARY                      ║
  ╠════════════════════════════════════════════════════════════════╣
  ║ Instance 1 (Read-only):  ${module.ec2.instance_public_ip}      ║
  ║ Instance 2 (Write-only): ${module.ec2.instance2_public_ip}     ║
  ║ S3 Bucket: ${module.ec2.bucket_name}                           ║
  ╠════════════════════════════════════════════════════════════════╣
  ║ SSH Commands:                                                  ║
  ║ ssh -i ~/.ssh/aws-lab-key ec2-user@${module.ec2.instance_public_ip}
  ║ ssh -i ~/.ssh/aws-lab-key ec2-user@${module.ec2.instance2_public_ip}
  ╚════════════════════════════════════════════════════════════════╝
  
  EOT
}

# ═══════════════════════════════════════════════════════════════
# KMS KEY INFO
# ═══════════════════════════════════════════════════════════════
output "kms_key_id" {
  description = "The ID of the KMS key for S3 bucket encryption"
  value       = module.iam.kms_key_id
}
output "kms_key_arn" {
  description = "The ARN of the KMS key for S3 bucket encryption"
  value       = module.iam.kms_key_arn
}
output "kms_key_alias" {
  description = "The alias of the KMS key for S3 bucket encryption"
  value       = module.iam.kms_key_alias
}