# Registros de pagamento do serviço de Pagamento (NoSQL). Chave de partição = ordem de serviço,
# chave de ordenação = orçamento: um pagamento por orçamento de cada OS. Sem streams e sem índices
# secundários — o serviço só consulta por OrdemServicoId (+ OrcamentoId).
resource "aws_dynamodb_table" "pagamentos" {
  name         = "${var.project_name}-${var.environment}-pagamentos"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "OrdemServicoId"
  range_key = "OrcamentoId"

  attribute {
    name = "OrdemServicoId"
    type = "S"
  }

  attribute {
    name = "OrcamentoId"
    type = "S"
  }

  tags = merge(local.common_tags, { Service = "pagamento" })
}
