output "db_endpoint" {
  description = "Endpoint (host:port) do RDS PostgreSQL."
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Hostname do RDS PostgreSQL, sem a porta."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Porta do RDS PostgreSQL."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco inicial no RDS (os bounded contexts vivem como schemas dentro dele — RFC-003 §4.1)."
  value       = aws_db_instance.this.db_name
}

output "db_secret_arn" {
  description = "ARN do secret no Secrets Manager com username/password/host/port/dbname. Nunca a senha em texto puro neste output."
  value       = aws_secretsmanager_secret.db.arn
}

output "db_security_group_id" {
  description = "Security group do RDS — referenciar para quem mais precisar de acesso à porta 5432."
  value       = aws_security_group.rds.id
}
