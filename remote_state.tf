# Consome a VPC, as subnets privadas e o security group do cluster EKS provisionados pelo
# repositório oficina-mecanica-infra-k8s (em desenvolvimento em paralelo). O bucket vem de
# variável — não hardcoded — pelo mesmo motivo do backend parcial em main.tf.
#
# Contrato assumido (documentado no README, seção "Contrato de outputs consumidos"): o state de
# infra-k8s exporta, no mínimo, `vpc_id`, `private_subnet_ids` e `cluster_security_group_id`.
#
# O state remoto ainda não existe enquanto o outro repositório não tiver rodado um `apply` — isso
# não impede `terraform validate` (data sources só são resolvidos no `plan`), mas impede `plan`
# e `apply` até lá.
data "terraform_remote_state" "infra_k8s" {
  backend = "s3"

  config = {
    bucket = var.infra_k8s_state_bucket
    key    = var.infra_k8s_state_key
    region = var.aws_region
  }
}

locals {
  vpc_id                = data.terraform_remote_state.infra_k8s.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.infra_k8s.outputs.private_subnet_ids
  eks_security_group_id = data.terraform_remote_state.infra_k8s.outputs.cluster_security_group_id
}
