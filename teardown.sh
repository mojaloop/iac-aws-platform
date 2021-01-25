#!/bin/sh

set -e
if [ -f ${CI_PROJECT_DIR}/terraform-k8s-postinstall.tfstate ]; then
  cd terraform/k8s-setup/addons
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="project_root_path=$CI_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s-postinstall.tfstate
else
  echo "terraform-k8s-postinstall.tfstate not found. Skipping terraform/k8s-setup/addons ..."
fi

if [ -f ${CI_PROJECT_DIR}/terraform-k8s.tfstate ]; then
  cd $CI_PROJECT_DIR/terraform/k8s-setup
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="project_root_path=$CI_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s.tfstate
else
  echo "terraform-k8s.tfstate not found. Skipping terraform/k8s-setup ..."
fi

if [ -f ${CI_PROJECT_DIR}/terraform-vault.tfstate ]; then
  cd $CI_PROJECT_DIR/terraform/k8s-setup/vault
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" -var="aws_access_key=$AWS_ACCESS_KEY_ID" -var="project_root_path=$CI_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-vault.tfstate
else
  echo "terraform-vault.tfstate not found. Skipping terraform/k8s-setup/vault ..."
fi

if [ -f ${CI_PROJECT_DIR}/terraform.tfstate ]; then
  cd $CI_PROJECT_DIR/terraform
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform.tfstate
else
  echo "terraform.tfstate not found. Skipping terraform ..."
fi

echo "Clearing remaining volumes"
for vol in $(aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/cluster/${ENVIRONMENT}-mojaloop,Values=owned" --query "Volumes[*].{id:VolumeId}" --region ${TF_VAR_region} | jq -r '.[].id'); do
  echo "  > deleting ${vol}"
  aws ec2 delete-volume --volume-id $vol --region ${TF_VAR_region}
done

echo "Clearing remaining ssh key pairs"
for keyid in $(aws ec2 describe-key-pairs --query "KeyPairs[*].{id:KeyPairId}" --filters Name=key-name,Values=${TF_VAR_client}-${ENVIRONMENT}-sdk-vm-ssh-key --region ${TF_VAR_region} | jq -r '.[].id'); do
  echo "  > deleting ${keyid}"
  aws ec2 delete-key-pair --key-pair-id $keyid --region ${TF_VAR_region}
done

echo "Clearing Terraform state"
for item in $(terraform state list); do
  terraform state rm -state=$item
done

aws s3 rm s3://$BUCKET/$ENVIRONMENT/ --recursive
echo "ENVIRONMENT $ENVIRONMENT DESTROYED"
