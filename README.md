# SSH KMS SSM Parameter

This project demonstrates secure SSH key management using AWS KMS and SSM Parameter Store.

## Features

- Store SSH keys securely in AWS SSM Parameter Store
- Encrypt/decrypt keys with AWS KMS
- Automated key retrieval for SSH connections

## Prerequisites

- AWS CLI configured
- Python 3.x
- Terraform installed
- IAM permissions for KMS and SSM

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/ssh-kms-ssm-parameter.git
    cd ssh-kms-ssm-parameter
    ```

2. Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```

## To setup ssh-key-kms 
3. Deploy ssh-key-kms with Terraform:

    ```bash
    cd module/
    terraform init
    terraform plan -var-file=../environments/client-a.tfvars
    terraform apply -var-file=../environments/client-a.tfvars
    ```
## To setup base infra 
4.  Deploy Infra modules with Terraform: 
    ```bash
    cd infra/
    terraform init
    terraform plan -var-file=../environments/client-a.tfvars
    terraform apply -var-file=../environments/client-a.tfvars
    ```
### To setup base infra one by one

```
# Init once
terraform init

# VPC
terraform apply -target=module.vpc -var-file=../environments/client-a.tfvars

# Security groups
terraform apply -target=module.securitygroup -var-file=../environments/client-a.tfvars

# Public NLB
terraform apply -target=module.nlb_public -var-file=../environments/client-a.tfvars

# Secondary Public NLB
terraform apply -target=module.nlb_public_secondary -var-file=../environments/client-a.tfvars

# Private NLB
terraform apply -target=module.nlb_private -var-file=../environments/client-a.tfvars

# OpenVPN ASG
terraform apply -target=module.openvpn_asg -var-file=../environments/client-a.tfvars

# Private VM ASG
terraform apply -target=module.private_vm_asg -var-file=../environments/client-a.tfvars

# Route53 failover
terraform apply -target=module.route53_failover_public_vpn -var-file=../environments/client-a.tfvars
```

#### How to get admin ssh key from SSM Parameter store

```
### Private Key
aws ssm get-parameter --name "/client-a/infra/ssh/admin/private" --with-decryption --query "Parameter.Value" --output text > ~/.ssh/client-a-admin.pem

### Public Key
aws ssm get-parameter --name "/client-a/infra/ssh/admin/public" --with-decryption --query "Parameter.Value" --output text > ~/.ssh/client-a-admin.pub
```


