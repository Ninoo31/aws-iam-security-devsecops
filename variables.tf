variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1"
}

variable "my_ip" {
  description = "Ton IP publique (format: x.x.x.x/32)"
  type        = string
}

variable "bucket_name" {
  description = "Nom du bucket S3 (doit être globalement unique)"
  type        = string
}