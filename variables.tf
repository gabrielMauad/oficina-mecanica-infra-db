variable "aws_region" {
  description = "Região AWS. A conta AWS Academy Learner Lab só permite us-east-1 e us-west-2 (RFC-002 §5)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo usado no nome dos recursos e no path do secret no Secrets Manager."
  type        = string
  default     = "oficina-mecanica"
}

variable "environment" {
  description = "Ambiente (usado em nomes de recursos e no path do secret)."
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = <<-EOT
    Nome do banco inicial criado no RDS. Os três bounded contexts da aplicação (cadastro,
    ordem_servico, pecas_insumos) vivem como schemas dentro dele, não como bancos separados
    (RFC-003 §4.1) — mesmo nome já usado em docker-compose.yml e nos manifests k8s da Fase 2.
  EOT
  type        = string
  default     = "oficina_mecanica"
}

variable "db_username" {
  description = "Usuário master do RDS."
  type        = string
  default     = "oficina"
}

variable "db_engine_version" {
  description = <<-EOT
    Versão do PostgreSQL (RFC-003 decide o motor). Informar apenas a major version (ex.: "16"),
    nunca pinar uma minor (ex.: "16.4"): o apply já falhou com
    "InvalidParameterCombination: Cannot find version 16.4 for postgres" porque a AWS aposenta
    minor versions do catálogo com o tempo. Com só a major version, o RDS seleciona a minor mais
    recente disponível; o provider trata engine_version como prefixo (não acusa drift quando a
    instância real vira "16.x") e expõe o valor efetivo em aws_db_instance.engine_version_actual.
  EOT
  type        = string
  default     = "16"
}

variable "db_instance_class" {
  description = "Classe da instância. A conta AWS Academy só permite classes burstable até 'medium' (RFC-002 §6.2)."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento em GB (gp2). A conta AWS Academy permite até 100 GB, sem PIOPS (RFC-002 §6.2)."
  type        = number
  default     = 20
}

variable "db_backup_retention_period" {
  description = "Dias de retenção de backup automático (1-7 — ambiente descartável, sem necessidade de retenção maior)."
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_period >= 1 && var.db_backup_retention_period <= 7
    error_message = "Use entre 1 e 7 dias de retenção (ambiente descartável — ver RFC-002 §6.3)."
  }
}

variable "infra_k8s_state_bucket" {
  description = <<-EOT
    Bucket S3 onde está o state do repositório oficina-mecanica-infra-k8s (mesmo bucket usado
    no backend deste repositório — RFC-002 §6.4 prevê um único bucket para todo o state do
    projeto). Sem default de propósito: não hardcodar nome de bucket real no código.
  EOT
  type        = string
}

variable "infra_k8s_state_key" {
  description = "Key do state remoto de oficina-mecanica-infra-k8s dentro do bucket compartilhado."
  type        = string
  default     = "infra-k8s/terraform.tfstate"
}
