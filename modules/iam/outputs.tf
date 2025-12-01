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