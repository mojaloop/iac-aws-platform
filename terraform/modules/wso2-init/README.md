# WSO2 Initialization

The purpose of this module is to setup all the requirements needed by the ISKM, Internal GW and External GW services.

This repo does the following:

- Deploys EFS to the environment and mounts it to the gateway cluster
- Creates EBS StorageClass on the gateway cluster
- Deploys into gateway cluster a MySQL DB (that uses created StorageClass) for all WSO2 applications
- Creates the intgw and extgw schemas
- Create the root CA and private key for use with other services
- Creates the Kubernetes Namespace where the services are later deployed into

Here is an example config to use with this module:

```terraform
module "wso2_init" {
  source = "../../modules/wso2-init"

  kubeconfig          = "${var.project_root_path}/admin-gateway.conf"
  environment         = var.environment
  mysql_version       = "1.6.1"
  db_root_password    = var.wso2_mysql_root_password
  db_password         = var.wso2_mysql_password
  efs_subnet_id       = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-wso2"]["id"]
  efs_security_groups = [data.terraform_remote_state.infrastructure.outputs.sg_id]
}
```

This example makes the following assumptions:

1. The EFS subnet ID and Security Groups were created in previous deployments and are referenced from their state files. You will need to ensure they are included in their `outputs`.
2. Not all available variables are defined in this example. This example makes heavy use of default values.

For a list of values and their default values see the [variables.tf](variables.tf) file.
