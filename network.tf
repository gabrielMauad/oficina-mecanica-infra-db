resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db"
  subnet_ids = local.private_subnet_ids

  tags = local.common_tags
}

resource "aws_security_group" "rds" {
  name = "${var.project_name}-${var.environment}-rds"
  # GroupDescription so aceita ASCII (exigencia da API da AWS) - nao reintroduzir acentos aqui.
  # O texto abaixo ficou desatualizado (cita a Function de autenticacao, que nao acessa mais o
  # banco), mas e mantido de proposito: "description" forca a recriacao do security group, o que
  # destruiria e recriaria tambem as regras dependentes e arriscaria DependencyViolation com as
  # interfaces de rede do RDS. A restricao real (somente o cluster EKS) esta na regra de ingress.
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

# Subnet group e security group são compartilhados pelas instâncias RDS de todos os serviços.
# Nenhum outro cliente acessa o banco: a Function de autenticação por CPF não usa mais banco
# (consulta o serviço de Cadastro por HTTP).
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Saida padrao, necessaria para manutencao/patch gerenciados pela AWS."
}
