resource "random_password" "db" {
  length = 32
  # Exclui '/', '@', '"' e espaço — caracteres não aceitos na senha master do RDS.
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  name        = "${var.project_name}/${var.environment}/rds/postgresql"
  description = "Credenciais do RDS PostgreSQL de ${var.project_name} (${var.environment})."

  # Ambiente descartável (AWS Academy Learner Lab): permite recriar o secret sem esperar a
  # janela de recovery padrão (7-30 dias) se o ambiente for destruído e reaplicado na mesma
  # sessão de laboratório. Em produção real esse valor seria maior que zero.
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "postgres"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
}
