# WSO2 External Gateway

The purpose of this module is to deploy Ext GW. It is dependent on the `wso2-init` module being executed first. Ext GW also depends on a functioning ISKM and depends on knowing the Helm release name used when deploying ISKM.

This repo does the following:

- Loads the static contents of the bin directory as a Config Map to the cluster
- Loads the static contents of the conf directory as a Config Map to the cluster
- Creates a self signed cert and private key, using the Root CA from `wso2-init`, and loads them as a Secret to the cluster
- Uses the Namespace created in the `wso2-init` module
- Helm installs the Ext GW application to the cluster

Here is an example config to use with this module:

```terraform
module "extgw" {
  source = "../../modules/ext-gw"

  kubeconfig         = "${var.project_root_path}/admin-gateway.conf"
  namespace          = var.wso2_namespace
  root_certificate   = module.wso2_init.root_certificate
  root_private_key   = module.wso2_init.root_private_key
  keystore_password  = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_password        = var.wso2_mysql_password
  contact_email      = "david.fry@modusbox.com"
  iskm_fqdn          = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  extgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  helm_release       = module.iskm.helm_release
  helm_deployment    = "wso2-is-km"
}
```

This example makes the following assumptions:

1. The execution of `wso2-init` is called using the module name "wso2_init"
2. Not all available variables are defined in this example. This example makes heavy use of default values.

For a list of values and their default values see the [variables.tf](variables.tf) file.
