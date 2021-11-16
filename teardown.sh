#!/bin/sh

set -e
if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform-k8s-postinstall.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-setup/addons
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="project_root_path=$CI_IMAGE_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s-postinstall.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform-k8s-postinstall.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform-k8s-postinstall.tfstate not found. Skipping terraform/k8s-setup/addons ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform-k8s-pm4mls.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-setup/pm4mls
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="project_root_path=$CI_IMAGE_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s-pm4mls.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform-k8s-pm4mls.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform-k8s-pm4mls.tfstate not found. Skipping terraform/k8s-setup/pm4mls ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform-k8s-mojaloop-roles.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-setup/mojaloop-roles
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="project_root_path=$CI_IMAGE_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s-mojaloop-roles.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform-k8s-mojaloop-roles.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform-k8s-mojaloop-roles.tfstate not found. Skipping terraform/k8s-setup/mojaloop-roles ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform-k8s.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-setup
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  #making sure to avoid failure on vault bug
  terraform destroy -auto-approve -var="project_root_path=$CI_IMAGE_PROJECT_DIR" || true
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-k8s.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform-k8s.tfstate-md5"}}' --return-values ALL_OLD
  aws s3 rm --recursive s3://$BUCKET/$ENVIRONMENT/wso2/
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/wso2/extgw/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform-k8s.tfstate not found. Skipping terraform/k8s-setup ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform-vault.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-setup/vault-deploy
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" -var="aws_access_key=$AWS_ACCESS_KEY_ID" -var="project_root_path=$CI_IMAGE_PROJECT_DIR"
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform-vault.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform-vault.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform-vault.tfstate not found. Skipping terraform/k8s-setup/vault-deploy ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform
  terraform init -backend-config ${CI_PROJECT_DIR}/backend.hcl
  terraform validate
  terraform destroy -auto-approve
  aws s3 rm s3://$BUCKET/$ENVIRONMENT/terraform.tfstate
  export DYNAMO_TABLE_NAME=$(echo $BUCKET | sed 's/-state/-lock/g')  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$BUCKET/$ENVIRONMENT'/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform.tfstate not found. Skipping terraform ..."
fi

echo "Clearing remaining volumes"
for vol in $(aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/cluster/${client]-${ENVIRONMENT}-mojaloop,Values=owned" --query "Volumes[*].{id:VolumeId}" --region ${TF_VAR_region} | jq -r '.[].id'); do
  echo "  > deleting ${vol}"
  aws ec2 delete-volume --volume-id $vol --region ${TF_VAR_region}
done
echo "Clearing Terraform state"
for item in $(terraform state list); do
  terraform state rm -state=$item
done

aws s3 rm s3://$BUCKET/$ENVIRONMENT/ --recursive
echo "ENVIRONMENT $ENVIRONMENT DESTROYED"
