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
3. Deploy ssh-key-kms  with Terraform:

    ```bash
    cd module/
    terraform init -var-file=../environments/client-a.tfvars
    terraform plan -var-file=../environments/client-a.tfvars
    terraform apply -var-file=../environments/client-a.tfvars
    ```
