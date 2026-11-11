output "databases" {
  description = "Mapa por serviço (cadastro, pecas-insumos, ordens-servico) com endpoint (host:port), address, port, db_name e secret_arn do RDS PostgreSQL do serviço. Nunca a senha — ela só existe no secret."
  value = {
    for servico, db in aws_db_instance.this : servico => {
      endpoint   = db.endpoint
      address    = db.address
      port       = db.port
      db_name    = db.db_name
      secret_arn = aws_secretsmanager_secret.db[servico].arn
    }
  }
}

output "db_security_group_id" {
  description = "Security group compartilhado pelas instâncias RDS — referenciar para quem mais precisar de acesso à porta 5432."
  value       = aws_security_group.rds.id
}

output "dynamodb_pagamentos_table_name" {
  description = "Nome da tabela DynamoDB de pagamentos."
  value       = aws_dynamodb_table.pagamentos.name
}

output "dynamodb_pagamentos_table_arn" {
  description = "ARN da tabela DynamoDB de pagamentos."
  value       = aws_dynamodb_table.pagamentos.arn
}
