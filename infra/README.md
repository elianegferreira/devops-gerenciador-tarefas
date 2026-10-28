# Infraestrutura como Código — Terraform

Esta pasta define, de forma declarativa, a infraestrutura AWS prevista para a **Fase 1**: um bucket Amazon S3 **privado** para artefatos do projeto. **O site não é publicado no S3 nesta fase.**

## Estrutura

| Arquivo | Finalidade |
| --- | --- |
| `main.tf` | Provider AWS, bucket, bloqueio de acesso público, versionamento e criptografia SSE-S3 |
| `variables.tf` | Região AWS e nome do bucket |
| `outputs.tf` | Nome, ARN e região do bucket, disponíveis após provisionamento |
| `terraform.tfvars.example` | Exemplo de valores de entrada, sem dados sensíveis |

**Requisitos:** Terraform compatível com `required_version >= 1.6.0`; provider AWS `~> 5.0`; para criar recursos reais, conta AWS, credenciais autorizadas e permissões mínimas para os recursos usados. O nome escolhido para o bucket deve estar disponível globalmente.

## Validação sem criar recursos

Na pasta `infra/`, executar:

```sh
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate -no-color
```

O [GitHub Actions](../.github/workflows/ci.yml) executa esses mesmos comandos a cada alteração enviada à branch principal e em pull requests direcionados a ela. A validação verifica formatação e configuração; **não comprova a criação do bucket na AWS**.

## Provisionamento real (opcional, fora da execução automática)

**Atenção:** realizar apenas com uma conta AWS autorizada, depois de verificar permissões e possíveis custos. Não publicar chaves de acesso nem estados do Terraform.

1. Configurar credenciais AWS por um mecanismo seguro (por exemplo, perfil AWS CLI ou identidade federada).
2. Escolher um nome globalmente único para o bucket. Pode criar `terraform.tfvars` localmente a partir de `terraform.tfvars.example` e alterar o valor de `bucket_name`. Esse arquivo está excluído do Git.
3. Em `infra/`, executar:

```sh
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
terraform output
```

O `terraform plan` **simula e apresenta as alterações**; o `terraform apply` solicita confirmação antes de criar os recursos (salvo uso deliberado de parâmetros que removam a confirmação).

Os outputs `bucket_name`, `bucket_arn` e `aws_region` identificam os recursos configurados. Para remover a infraestrutura, após confirmar os impactos, pode-se executar `terraform destroy -var-file="terraform.tfvars"`. Se o bucket tiver objetos, poderá ser necessário esvaziá-lo de forma segura antes da destruição.

## Segurança e custos

- O acesso público está bloqueado pelas quatro configurações de `aws_s3_bucket_public_access_block`.
- O bucket usa versionamento e criptografia padrão SSE-S3 (AES256).
- Os arquivos de estado `*.tfstate`, variáveis `*.tfvars` e credenciais não devem ser enviados ao repositório.
- O S3 pode gerar custos de armazenamento, pedidos e transferência, mesmo em projetos pequenos. A existência de um possível nível gratuito não garante custo zero.

**Estado documentado:** scripts versionados e validados automaticamente; o provisionamento real não foi realizado.
