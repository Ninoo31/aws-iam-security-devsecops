output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.ec2_s3_access.arn
}

output "instance_profile_write_only_name" {
  description = "The name of the IAM instance profile with write only access"
  value       = aws_iam_instance_profile.ec2_write_only_profile.name

}

output "kms_key_id" {
  description = "The ID of the KMS key for S3 bucket encryption"
  value       = aws_kms_key.s3_encryption_key.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key for S3 bucket encryption"
  value       = aws_kms_key.s3_encryption_key.arn
}

output "kms_key_alias" {
  description = "The alias of the KMS key for S3 bucket encryption"
  value       = aws_kms_alias.s3_encryption_key_alias.name
}

output "vpc_flow_role_arn" {
  description = "the arn of the vpc flow role"
  value       = aws_iam_role.vpc_flow_log_role.arn
}