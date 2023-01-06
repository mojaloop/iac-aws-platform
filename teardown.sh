#!/bin/sh

set -e
export DYNAMO_TABLE_NAME=$(echo $bucket | sed 's/-state/-lock/g') 

if [ -f ${CI_IMAGE_PROJECT_DIR}/k8s-apps-setup/post-config/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-apps-setup/post-config
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/k8s-apps-setup/post-config/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/post-config/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "k8s-apps-setup/post-config/terraform.tfstate not found. Skipping k8s-apps-setup/post-config ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/k8s-apps-setup/mojaloop-core/mojaloop-roles/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-apps-setup/mojaloop-core/mojaloop-roles
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/k8s-apps-setup/mojaloop-core/mojaloop-roles/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/mojaloop-core/mojaloop-roles/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "k8s-apps-setup/mojaloop-core/mojaloop-roles/terraform.tfstate not found. Skipping k8s-apps-setup/mojaloop-core/mojaloop-roles ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/k8s-apps-setup/mojaloop-core/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-apps-setup/mojaloop-core
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/k8s-apps-setup/mojaloop-core/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/mojaloop-core/terraform.tfstate-md5"}}' --return-values ALL_OLD
  aws s3 rm --recursive s3://$bucket/$environment/k8s-apps-setup/apps/wso2
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/apps/wso2/config/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "k8s-apps-setup/mojaloop-core/terraform.tfstate  not found. Skipping k8s-apps-setup/mojaloop-core ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/k8s-apps-setup/support-svcs/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-apps-setup/support-svcs
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/k8s-apps-setup/support-svcs/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/support-svcs/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "k8s-apps-setup/support-svcs/terraform.tfstate not found. Skipping k8s-apps-setup/support-svcs ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/k8s-apps-setup/state-setup/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/k8s-apps-setup/state-setup
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/k8s-apps-setup/state-setup/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/k8s-apps-setup/state-setup/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "k8s-apps-setup/state-setup/terraform.tfstate not found. Skipping k8s-apps-setup/state-setup..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/base-k8s-setup/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/base-k8s-setup
  cp $ENV_S3_DIR/vault/vault_seal_key $CI_IMAGE_PROJECT_DIR/static_files/ || true
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" -var="aws_access_key=$AWS_ACCESS_KEY_ID"
  aws s3 rm s3://$bucket/$environment/vault/vault_seal_key
  aws s3 rm s3://$bucket/$environment/base-k8s-setup/terraform.tfstate
  
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/base-k8s-setup/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "base-k8s-setup/terraform.tfstate not found. Skipping base-k8s-setup ..."
fi

if [ -f ${CI_IMAGE_PROJECT_DIR}/base-infra-aws/terraform.tfstate ]; then
  cd $CI_IMAGE_PROJECT_DIR/terraform/base-infra-aws
  terragrunt init
  terragrunt validate
  terragrunt destroy -auto-approve
  aws s3 rm s3://$bucket/$environment/base-infra-aws/terraform.tfstate
  aws --region $region dynamodb delete-item --table-name $DYNAMO_TABLE_NAME --key '{"LockID": {"S": '\"$bucket/$environment'/base-infra-aws/terraform.tfstate-md5"}}' --return-values ALL_OLD
else
  echo "terraform.tfstate not found. Skipping terraform ..."
fi

echo "Clearing remaining volumes"
for vol in $(aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/cluster/${client}-${environment}-mojaloop,Values=owned" --query "Volumes[*].{id:VolumeId}" --region $region | jq -r '.[].id'); do
  echo "  > deleting ${vol}"
  aws ec2 delete-volume --volume-id $vol --region $region
done
# echo "Clearing Terraform state"
# for item in $(terraform state list); do
#   terraform state rm -state=$item
# done

aws s3 rm s3://$bucket/$environment/ --recursive
echo "environment $environment DESTROYED"
