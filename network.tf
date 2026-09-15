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

# A regra que libera a porta 5432 para a Function oficina-mecanica-lambda-auth NÃO é criada aqui.
# O security group da Lambda nasce no próprio repositório oficina-mecanica-lambda-auth, então a
# regra de ingress também é declarada lá (lendo db_security_group_id deste repositório via
# terraform_remote_state) — evita um re-apply cruzado entre repositórios toda vez que o SG da
# Lambda mudar. Ver README, seção "Contrato de outputs".
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Saida padrao, necessaria para manutencao/patch gerenciados pela AWS."
}
