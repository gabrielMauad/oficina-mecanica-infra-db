# oficina-mecanica-infra-db

Terraform do banco de dados gerenciado do **Sistema de Oficina Mecânica** — Tech Challenge da
pós-graduação em Arquitetura de Software (FIAP/SOAT), Fase 3.

> **Estado atual: esqueleto.** Este repositório ainda não provisiona nenhum recurso de nuvem. A
> escolha do provedor (AWS/GCP/Azure) é uma RFC pendente (RFC-002, no repositório
> [`oficina-mecanica-app`](https://github.com/gabrielMauad/oficina-mecanica-app)). Até essa decisão,
> não há região, ARN, tipo de instância ou credencial reais para declarar aqui — o que existe é a
> estrutura, o `.gitignore` e a pipeline de validação, prontos para receber o Terraform de verdade
> por Pull Request.

---

## Índice

- [Propósito](#propósito)
- [Tecnologias utilizadas](#tecnologias-utilizadas)
- [Diagrama do componente](#diagrama-do-componente)
- [Pré-requisitos](#pré-requisitos)
- [Instruções de execução](#instruções-de-execução)
- [Passos de deploy](#passos-de-deploy)
- [Explicação da pipeline](#explicação-da-pipeline)
- [Decisões e pontos em aberto](#decisões-e-pontos-em-aberto)

---

## Propósito

Provisionar, via Terraform, o **banco de dados gerenciado** (ex.: Amazon RDS PostgreSQL) que
substitui o PostgreSQL em pod usado na Fase 2: subnet group privado, security group liberando
apenas o cluster Kubernetes (`oficina-mecanica-infra-k8s`) e a Function de autenticação
(`oficina-mecanica-lambda-auth`), backup/retention, e as credenciais publicadas em um cofre de
segredos (ex.: Secrets Manager / SSM Parameter Store) — nunca em texto puro.

## Tecnologias utilizadas

| Tecnologia | Uso |
|---|---|
| **Terraform** ≥ 1.5 | IaC do banco gerenciado e da rede/segurança ao redor dele |
| **GitHub Actions** | CI de validação (`fmt` + `validate`) em Pull Request |
| Provedor de nuvem | **A decidir** (RFC-002) — candidato natural: AWS (Amazon RDS PostgreSQL), para manter o mesmo motor (PostgreSQL 16) já usado nas Fases 1 e 2 |

## Diagrama do componente

```mermaid
flowchart LR
    subgraph Nuvem["Nuvem — provedor a definir (RFC-002)"]
        K8S["Cluster Kubernetes<br/>oficina-mecanica-infra-k8s"]
        LAMBDA["Function de autenticação<br/>oficina-mecanica-lambda-auth"]
        subgraph DBNET["Rede privada do banco — este repositório"]
            DB[("Banco de dados gerenciado<br/>(ex.: Amazon RDS PostgreSQL)")]
        end
        SECRETS[["Cofre de segredos<br/>(ex.: Secrets Manager)"]]
    end
    K8S -->|lê/escreve, via credencial do cofre| DB
    LAMBDA -->|SELECT somente leitura, via credencial do cofre| DB
    SECRETS -.credenciais.-> K8S
    SECRETS -.credenciais.-> LAMBDA
```

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.5
- Hoje **não há mais nada a instalar**: sem provider declarado, não há credencial de nuvem para
  configurar. Isso muda assim que a RFC-002 for decidida — este README será atualizado com as
  credenciais/variáveis de ambiente necessárias (via secrets do GitHub, nunca commitadas).

## Instruções de execução

O único fluxo que faz sentido hoje é a validação estática, a mesma que a pipeline roda em cada PR:

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

Não existe `terraform plan`/`apply` possível ainda: não há provider nem recursos declarados (ver
[Decisões e pontos em aberto](#decisões-e-pontos-em-aberto)). Descrever um passo a passo de plan/apply
aqui seria documentar um comando que não funciona — por isso não há um.

## Passos de deploy

Pendente da decisão de nuvem (RFC-002). Quando definida, o fluxo será:

1. PR com o Terraform real (provider, backend remoto, recursos do banco).
2. CI roda `terraform fmt -check` + `terraform validate` — status check obrigatório da `main`.
3. Merge em `main`.
4. `terraform apply` automático (hoje comentado no workflow) contra o backend remoto de state,
   usando credenciais/role OIDC configuradas como secret deste repositório.

Ordem de dependência a respeitar quando os três repositórios de infraestrutura existirem: este
repositório (banco) é aplicado **antes** de `oficina-mecanica-infra-k8s`, já que o cluster/a Lambda
consomem o endpoint do banco via `terraform_remote_state` ou SSM.

## Explicação da pipeline

Workflow em [`.github/workflows/ci.yml`](.github/workflows/ci.yml), GitHub Actions:

- **Em Pull Request** (job `validate`): `terraform fmt -check -recursive`, `terraform init
  -backend=false` e `terraform validate`. É o **status check obrigatório** da branch `main` — sem
  ele passar, o PR não pode ser mergeado.
- **Apply**: job `apply` **comentado** no workflow. Depende de três coisas que ainda não existem:
  a decisão de nuvem (RFC-002), o backend remoto do state (bucket S3 + DynamoDB, ou equivalente do
  provedor escolhido) e credenciais/role OIDC como secret deste repositório. O TODO no arquivo
  documenta exatamente essa dependência — não é um esquecimento.

## Decisões e pontos em aberto

- **Sem Dockerfile.** A orientação oficial da fase é incluir `Dockerfile` só onde for tecnicamente
  necessário; um repositório composto apenas de Terraform não roda nada em contêiner. Decisão, não
  esquecimento.
- **Sem provider/recurso ainda.** Depende da decisão de nuvem (RFC-002). Não foi inventado nenhum
  recurso, região, ARN ou credencial para preencher este repositório antes da hora.
- **Ambiente de homologação**: em aberto (ver ADR-005 do repositório da aplicação) — depende do
  crédito disponível na conta de nuvem usada no projeto.
