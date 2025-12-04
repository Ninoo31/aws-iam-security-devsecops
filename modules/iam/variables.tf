variable "bucket_name" {
  description = "The S3 bucket to which EC2 will have read-only access"
  type        = string
}

variable "aws_cloudwatch_log_group_arn" {
  description = "The aws cloudwatch log group arn"
  type = string
}