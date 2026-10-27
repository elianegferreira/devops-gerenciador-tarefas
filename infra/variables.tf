variable "aws_region" {
  description = "Região onde os recursos serão provisionados."
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Nome globalmente único do bucket S3."
  type        = string
}
