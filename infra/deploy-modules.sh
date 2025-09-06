#!/bin/bash
set -euo pipefail

# Usage:
#   ./deploy-modules.sh apply ../environments/client-a.tfvars
#   ./deploy-modules.sh destroy ../environments/client-a.tfvars

if [ $# -lt 2 ]; then
  echo "Usage: $0 <apply|destroy> <path-to-tfvars>"
  echo "Example: $0 apply ../environments/client-a.tfvars"
  exit 1
fi

ACTION=$1
TFVARS=$2

if [[ "$ACTION" != "apply" && "$ACTION" != "destroy" ]]; then
  echo "Error: first argument must be 'apply' or 'destroy'"
  exit 1
fi

if [ ! -f "$TFVARS" ]; then
  echo "Error: tfvars file not found at $TFVARS"
  exit 1
fi

echo ">>> Using action: $ACTION"
echo ">>> Using tfvars file: $TFVARS"

echo ">>> Initializing Terraform"
terraform init

if [ "$ACTION" == "apply" ]; then
  # --- Apply modules in creation order ---
  terraform $ACTION -target=module.vpc                       -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.securitygroup             -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_public                -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_public_secondary      -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_private               -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.openvpn_asg               -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.private_vm_asg            -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.route53_failover_public_vpn -var-file=$TFVARS -auto-approve
else
  # --- Destroy modules in reverse order ---
  terraform $ACTION -target=module.route53_failover_public_vpn -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.private_vm_asg            -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.openvpn_asg               -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_private               -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_public_secondary      -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.nlb_public                -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.securitygroup             -var-file=$TFVARS -auto-approve
  terraform $ACTION -target=module.vpc                       -var-file=$TFVARS -auto-approve
fi

echo ">>> Modules $ACTION completed."
