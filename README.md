# Lab de uso do AWS EC2 com Load Balancer (Terraform)

Objetivo: explorar na prática os conceitos de computação em nuvem utilizando os serviços **AWS Elastic Compute Cloud (EC2)** e **AWS EC2 Elastic Load Balancing (ALB)**, através da automação com Terraform.

---

## 📋 PRIMEIROS PASOS (Pré-requisitos)

Antes de começar, verifique se tem o que precisa:

### 1. Conta AWS
- Ter uma conta na AWS (criada em https://aws.amazon.com/)
- Permissões para criar: VPC, EC2, ELB (Application Load Balancer), Security Groups

### 2. Chave SSH
- Ter a chave `vockey` já criada na região `us-east-1`
- Ou criar uma nova chave pelo console AWS antes de rodar o Terraform

### 3. GitHub Account (para pipeline)
- Conta no GitHub (https://github.com/)
- Para usar a pipeline automatizada, será necessário adicionar dois **Segredos** no repositório:
  - `ACCESS_KEY_ID` - AWS Access Key ID
  - `SECRET_ACCESS_KEY` - AWS Secret Access Key

### 4. Terraform instalado (opcional, para uso local)
- Pode instalar seguindo https://developer.hashicorp.com/terraform/tutorials/cli/install

---

## 🏗️ FASE 1: PROVISIONAMENTO (Criar a infraestrutura)

Há duas formas de provisionar: **via GitHub Actions (recomendado)** ou **localmente no seu computador**.

### OPÇÃO A: Via GitHub Actions (Automatizado)

Esta é a forma recomendada para labs, pois tudo é automático pelo GitHub.

#### Passo 1: Acesse o repositório
- Acesse o repositório do projeto no GitHub

#### Passo 2: Execute o workflow
1. Na aba **Actions** no topo do repositório
2. Clique em "Terraform AWS EC2 + ALB Deploy"
3. Clique no botão **"Run workflow"** (no canto direito superior)
4. Deixe os campos como estão (branch: main) e clique em **"Run workflow"**

#### Passo 3: Acompanhe a execução
- O workflow terá 7 etapas rodando sequencialmente:
  1. **Terraform Init** - Baixa os providers e modules necessários
  2. **Terraform Validate** - Verifica se o código Terraform está sintaticamente correto
  3. **Terraform Format Check** - Verifica se o código está devidamente formatado
  4. **Terraform Plan** - Cria um plano do que será criado (shows o que vai acontecer)
  5. **Checkov Scan** - **Escaneia segurança** (informativo - não quebra se achar issues)
  6. **Terraform Apply** - **Cria todos os resources** (VPC, EC2, ALB, SG, etc.)
  7. **Terraform Destroy** - (Opcional) Só roda se você disparar novamente purposefully

#### Passo 4: Anote o DNS do Balanceador
- Depois que o workflow finalizar (etapa 6), vá na etapa "Terraform Apply"
- Role até encontrar o output `lb_dns_name`
- Copie esse valor - será o endereço do balanceador

#### Passo 5: Acesse no navegador
- Abra uma nova aba e acesse: `http://<o-dns-que-voce-copiou>`
- Você verá uma página PHP com informações do sistema
- **Teste**: Atualize (F5) a página algumas vezes - a linha "System" mudará, mostrando que o balanceador está distribuindo tráfego entre as 2 instâncias

---

### OPÇÃO B: Localmente no seu computador

Se preferir rodar no seu próprio máquina (exige Terraform instalado):

#### Passo 1: Clone ou acesse o projeto
```bash
# Se tiver git
git clone <url-do-repositorio>
cd trabalho_terraform/terraform
```

#### Passo 2: Inicialize o Terraform
```bash
terraform init
```
- Isso vai baixar o provider AWS e os modules necessários
- Pode demorar alguns minutos na primeira vez

#### Passo 3: Revise o que será criado
```bash
terraform plan
```
- Vai mostrar tudo o que será criado
- Verifique se concorda com as mudanças
- **Dica**: Se quiser salvar esse plano: `terraform plan -out=tfplan`

#### Passo 4: Aplique a infraestrutura
```bash
terraform apply
```
- O Terraform vai perguntar `Do you want to perform these actions?`
- Digite `yes` e aperte Enter
- Aguarde o processo terminar (pode levar 5-10 minutos)

#### Passo 5: Capture o DNS do Balanceador
- Depois do `apply` completar, o Terraform vai mostrar outputs
- Anote o valor de `lb_dns_name` que será exibido
- **Ou** depois: `terraform output lb_dns_name`

#### Passo 6: Acesse no navegador
```bash
http://<seu-lb-dns-name>
```
- Veja a página PHP
- Atualize várias vezes para ver o balanceamento em ação

---

## ✅ FASE 2: VALIDAÇÃO (Confirmar que está funcionando)

Depois de provisionado, faça essas validações:

### 1. Verifique as instâncias EC2
- No console AWS, vá em **EC2 → Instâncias**
- Deve aparecer 2 instâncias (uma em us-east-1a, outra em us-east-1b)
- O status deve estar `Running` e `2/2 verificações aprovadas`

### 2. Teste o balanceamento
No navegador, acesse o DNS do balanceador e:
- **Atualize a página (F5) pelo menos 5 vezes**
- Observe a linha "System" na parte superior da página
- Ela deve mudar de valor a cada atualização, indicando que o ALB está direcionando para instâncias diferentes

### 3. Verifique o Security Group
- No console AWS, vá em **EC2 → Security Groups**
- Deve ter regras para:
  - SSH (porta 22) - para acesso remoto
  - HTTP (porta 80) - para o balanceador
  - ICMP - para ping
  - **Sem regra para FTP (porta 21)** - bloqueado por omissão

### 4. Verifique os IPs
- As instâncias devem ter IPs públicos atribuídos (devido ao `map_public_ip_on_launch = true` nas subnets)
- Pode tentar acessar diretamente o IP da instância, mas o balanceador é o ponto de entrada recomendado

---

## 🗑️ FASE 3: DESTRUIÇÃO (Limpar recursos)

### Importante: Evitar custos indesejados!

Recursos AWS geram custos quando estão rodando. Sempre destrua ao finalizar.

### OPÇÃO A: Via GitHub Actions (Recomendado)

#### Passo 1: Acesse o workflow
1. Na aba **Actions** do repositório
2. Clique em "Terraform AWS EC2 + ALB Deploy"
3. Você verá dois jobs disponíveis:
   - `terraform-apply` (já foi executado)
   - `terraform-destroy` (novo)

#### Passo 2: Execute o destroy
1. Clique no job `terraform-destroy`
2. Clique em **"Run workflow"** no canto direito
3. Confirme em "Run workflow" novamente

#### Passo 3: Aguarde a conclusão
- O workflow vai rodar o `terraform destroy -auto-approve`
- Vai remover todos os resources: VPC, EC2, ALB, SGs, subnets, etc.
- Quando finalizar, todos os recursos AWS serão removidos e você deixará de pagar por eles

### OPÇÃO B: Localmente no seu computador

```bash
terraform destroy
```

- O Terraform vai perguntar para confirmar
- Digite `yes` e aperte Enter
- Aguarde a remoção de todos os resources
- **Verifique no console AWS** depois de terminar para confirmar que tudo foi removido

---

## 📊 RESUMO DA ARQUITETURA CRIADA

Ao final do provisionamento, você terá:

| Recurso | Quantidade | Localização |
|---------|-----------|-------------|
| **VPC** | 1 | Rede privada isolada |
| **Subnets Públicas** | 2 | us-east-1a e us-east-1b |
| **Internet Gateway** | 1 | Para acesso à internet |
| **EC2 Instances** | 2 | 1 por AZ, rodando Apache+PHP |
| **Application Load Balancer** | 1 | Distribuindo tráfego HTTP:80 |
| **Target Group** | 1 | Registrando os 2 destinos (EC2) |
| **Security Group** | 1 | Com regras: SSH(22), HTTP(80), ICMP, FTP negado |

### Outputs disponíveis (para consultar depois):
- `lb_dns_name` - Endereço para acessar o balanceador
- `instance_a_id` - ID da instância na us-east-1a
- `instance_b_id` - ID da instância na us-east-1b
- `sg_id_compute` - ID do Security Group

---

## ⚠️ PONTOS DE ATRICÃO COMUNS

### 1. "Terraform plan demora muito tempo"
- É normal na primeira vez que baixa os providers
- Espere completar, não feche o terminal

### 2. "Erro ao criar instância EC2"
- Verifique se a chave SSH `vockey` existe na região us-east-1
- Verifique se as subnets estão corretas

### 3. "Não consigo acessar o balanceador"
- Aguarde alguns minutos após o `apply` completar (o DNS pode demorar para propagar)
- Certifique-se de estar usando `http://` e não `https://`

### 4. "Quero parar de pagar pelos recursos"
- Use a **Fase 3 (Destroy)** do guia acima
- O destroy via GitHub Actions é gratuito (só consome tempo de execução do workflow)

---

## 🆘 PRECISANDO DE AJUDA?

1. **Verifique os logs**: No GitHub Actions, clique na etapa que deu erro e role para baixo - os erros geralmente aparecem no final
2. **Consulte a documentação**: Os links no final do README (AWS EC2 e AWS ELB)
3. **Reinicialize**: Se ficar travado, rode `terraform init` novamente e depois `terraform apply`

---

## 📚 REFERÊNCIAS

- [AWS EC2 Documentation](https://aws.amazon.com/pt/ec2/)
- [AWS ELB Documentation](https://aws.amazon.com/pt/elasticloadbalancing/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)