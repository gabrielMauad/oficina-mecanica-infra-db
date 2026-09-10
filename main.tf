# Bootstrap do módulo Terraform de infraestrutura do banco de dados gerenciado.
#
# Ainda não há provider nem recursos declarados: a nuvem (AWS/GCP/Azure) está
# pendente de decisão em RFC-002, no repositório da aplicação. Este arquivo
# existe só para que `terraform fmt` e `terraform validate` tenham algo
# válido para checar desde o primeiro Pull Request.
#
# Quando a nuvem for decidida, entram aqui (ou em arquivos novos, por
# recurso): bloco de provider com backend remoto (ex.: S3 + DynamoDB lock),
# subnet group privado, security group liberando só o cluster Kubernetes e a
# Function de autenticação, a instância do banco gerenciado (ex.: Amazon RDS
# PostgreSQL) com backup/retention configurados, e as credenciais em um
# cofre de segredos (ex.: Secrets Manager / SSM Parameter Store).

terraform {
  required_version = ">= 1.5"
}
