# Uma instância RDS por serviço com banco relacional. Cada serviço é dono dos seus dados e tem
# credencial própria; o isolamento é feito só com Terraform (instância + senha + secret), sem
# criar databases ou usuários por SQL numa rede privada.
#
# A chave do mapa é o nome do serviço (usado no identifier da instância e no path do secret);
# `db_name` é o database criado dentro da instância. Os schemas de cada módulo continuam os
# mesmos dentro do database — as migrations das aplicações não mudam.
locals {
  bancos = {
    "cadastro"       = { db_name = "cadastro" }
    "pecas-insumos"  = { db_name = "pecas_insumos" }
    "ordens-servico" = { db_name = "ordens_servico" }
  }
}

resource "aws_db_instance" "this" {
  for_each = local.bancos

  identifier     = "${var.project_name}-${var.environment}-${each.key}"
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = each.value.db_name
  username = var.db_username
  password = random_password.db[each.key].result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # RFC-002 §7: Multi-AZ não é usado — o desenho não depende de HA do banco para a demonstração,
  # e a lista de serviços da conta não garante suporte a Multi-AZ no Learner Lab.
  multi_az = false

  backup_retention_period = var.db_backup_retention_period

  # Enhanced monitoring não é suportado na conta AWS Academy (RFC-002 §6.2) — precisa ficar
  # explicitamente desligado, já que vários módulos/defaults ligam essa opção sozinhos.
  monitoring_interval          = 0
  performance_insights_enabled = false

  # Ambiente descartável (Tech Challenge, RFC-002 §6.3): em produção real,
  # skip_final_snapshot seria false, com um final_snapshot_identifier definido, para preservar
  # os dados antes de um destroy.
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = merge(local.common_tags, { Service = each.key })
}
