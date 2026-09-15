resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db"
  subnet_ids = local.private_subnet_ids

  tags = local.common_tags
}

resource "aws_security_group" "rds" {
  name = "${var.project_name}-${var.environment}-rds"
  # GroupDescription so aceita ASCII (exigencia da API da AWS) - nao reintroduzir acentos aqui.
  description = "Permite PostgreSQL (5432) apenas a partir do cluster EKS e da Function de autenticacao."
  vpc_id      = local.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "postgres_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = local.eks_security_group_id
  description              = "Cluster EKS (oficina-mecanica-infra-k8s)"
}

# Condicional: o repositório da Lambda ainda não expõe um security group formal (ver
# variables.tf, lambda_security_group_id). Enquanto isso não existir, esta regra não é criada.
resource "aws_security_group_rule" "postgres_from_lambda" {
  count = var.lambda_security_group_id != null && var.lambda_security_group_id != "" ? 1 : 0

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.lambda_security_group_id
  description              = "Function oficina-mecanica-lambda-auth"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Saida padrao, necessaria para manutencao/patch gerenciados pela AWS."
}
