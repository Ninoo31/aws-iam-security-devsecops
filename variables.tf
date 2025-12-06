variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "my_ip" {
  description = "Your Pubilic IP (format: x.x.x.x/32)"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "notification_email" {
  description = "Email subscription for s3 topic notification"
  type        = string
  default     = ""
}