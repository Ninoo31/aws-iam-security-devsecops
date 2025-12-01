# ═══════════════════════════════════════════════════════════════
# OUTPUTS - Instance 1 (Read-only)
# ═══════════════════════════════════════════════════════════════

output "instance_public_ip" {
  description = "Elastic IP of the read-only instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_id" {
  description = "ID of the read-only instance"
  value       = aws_instance.app.id
}

output "instance_private_ip" {
  description = "Private IP of the read-only instance"
  value       = aws_instance.app.private_ip
}

# ═══════════════════════════════════════════════════════════════
# OUTPUTS - Instance 2 (Write-only)
# ═══════════════════════════════════════════════════════════════

output "instance2_public_ip" {
  description = "Elastic IP of the write-only instance"
  value       = aws_eip.app_eip2.public_ip
}

output "instance2_id" {
  description = "ID of the write-only instance"
  value       = aws_instance.app2.id
}

output "instance2_private_ip" {
  description = "Private IP of the write-only instance"
  value       = aws_instance.app2.private_ip
}

# ═══════════════════════════════════════════════════════════════
# OUTPUTS - S3 Bucket
# ═══════════════════════════════════════════════════════════════

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.test_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.test_bucket.arn
}