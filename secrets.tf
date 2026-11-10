# Senha própria por instância: o vazamento da credencial de um serviço não dá acesso aos dados
# dos outros.
resource "random_password" "db" {
  for_each = local.bancos

  length = 32
  # Exclui '/', '@', '"' e espaço — caracteres não aceitos na senha master do RDS.
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  for_each = local.bancos

  name        = "${var.project_name}/${var.environment}/rds/${each.key}"
  description = "Credenciais do RDS PostgreSQL do servico ${each.key} de ${var.project_name} (${var.environment})."

  # Ambiente descartável (AWS Academy Learner Lab): permite recriar o secret sem esperar a
  # janela de recovery padrão (7-30 dias) se o ambiente for destruído e reaplicado na mesma
  # sessão de laboratório. Em produção real esse valor seria maior que zero.
  recovery_window_in_days = 0

  tags = merge(local.common_tags, { Service = each.key })
}

resource "aws_secretsmanager_secret_version" "db" {
  for_each = local.bancos

  secret_id = aws_secretsmanager_secret.db[each.key].id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db[each.key].result
    engine   = "postgres"
    host     = aws_db_instance.this[each.key].address
    port     = aws_db_instance.this[each.key].port
    dbname   = each.value.db_name
  })
}
