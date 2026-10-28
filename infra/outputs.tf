output "bucket_name" {
  description = "Nome do bucket S3 criado para armazenar artefatos."
  value       = aws_s3_bucket.artifacts.id
}

output "bucket_arn" {
  description = "ARN do bucket S3 criado."
  value       = aws_s3_bucket.artifacts.arn
}

output "aws_region" {
  description = "Região AWS usada no provisionamento."
  value       = var.aws_region
}
