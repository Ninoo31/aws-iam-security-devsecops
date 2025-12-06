variable "bucket_name" {
  description = "The name of the S3 bucket to be created"
  type        = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_profile_write_only_name" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "notification_email" {
  type = string
}