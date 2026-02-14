# eks-gitops-infra

Este projeto utiliza Terraform para provisionar uma infraestrutura completa na AWS, incluindo:

- VPC customizada
- Cluster EKS (Kubernetes)

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Permissões adequadas na AWS para criar recursos (VPC, EKS, IAM, etc)

## Estrutura do Projeto

```
eks-gitops-infra/
├── apps/
│   └── kibana/
│       ├── Application.yml
│       └── values.yml
├── infra/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfstate*
│   ├── terraform.tfvars
│   └── variables.tf
└── Makefile
```

## Como usar

1. **Configure as variáveis**
   - Edite o arquivo `infra/terraform.tfvars` com os valores desejados (nome do cluster, região, CIDR, etc).

2. **Inicialize o Terraform**
   ```sh
   cd infra
   terraform init
   ```

3. **Valide o plano**
   ```sh
   terraform plan
   ```

4. **Aplique a infraestrutura**
   ```sh
   terraform apply
   ```

5. **Acesse o Argo CD**
   - O Argo CD será exposto via LoadBalancer na AWS. Use o comando abaixo para obter o endereço:
     ```sh
     kubectl get svc -n argocd
     ```
   - O usuário padrão é `admin`. Para obter a senha:
     ```sh
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
     ```

## Observações

- O provisionamento do EKS pode demorar alguns minutos.
- Certifique-se de que sua máquina tem acesso à VPC do EKS para aplicar recursos Kubernetes/Helm.
- Caso ocorra erro de timeout ou recurso não encontrado, aguarde e execute `terraform apply` novamente.

## Licença

MIT
