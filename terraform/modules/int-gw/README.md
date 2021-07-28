# WSO2 Internal Gateway

The purpose of this module is to deploy Int GW. It is dependent on the `wso2-init` module being executed first. Int GW also depends on a functioning ISKM. However this module can be deployed at the same time as ISKM as the application can handle it.

This repo does the following:

- Loads the static contents of the bin directory as a Config Map to the cluster
- Loads the static contents of the conf directory as a Config Map to the cluster
- Creates a self signed cert and private key, using the Root CA from `wso2-init`, and loads them as a Secret to the cluster
- Creates a public and private key for JWS and loads them in the same Secret
- Uses the Namespace created in the `wso2-init` module
- Helm installs the Int GW application to the cluster

Here is an example config to use with this module:

```terraform
module "intgw" {
  source = "../modules/int-gw"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = var.wso2_namespace
  root_certificate = tls_self_signed_cert.ca_cert.cert_pem
  root_private_key = module.wso2_init.root_private_key
  keystore_password  = "wso2carbon"
  jws_password       = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_password        = var.wso2_mysql_password
  contact_email      = "cicd@modusbox.com"
  iskm_fqdn          = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  intgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
}
```

This example makes the following assumptions:

1. The execution of `wso2-init` is called using the module name "wso2_init"
2. Not all available variables are defined in this example. This example makes heavy use of default values.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| helm | ~> 0.10.6 |
| kubernetes | ~> 1.11 |
| tls | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| helm | ~> 0.10.6 |
| kubernetes | ~> 1.11 |
| tls | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| contact\_email | Email address to associate with Certs | `string` | n/a | yes |
| db\_password | User password ised to access DB service | `string` | n/a | yes |
| intgw\_fqdn | FQDN of Int GW service | `string` | n/a | yes |
| iskm\_fqdn | FQDN of ISKM service | `string` | n/a | yes |
| jws\_password | Mojaloop JWS password | `string` | n/a | yes |
| keystore\_password | JKS password | `string` | n/a | yes |
| kubeconfig | Path to kubernetes config file | `string` | n/a | yes |
| public\_domain\_name | Domain name for Internal GW service | `string` | n/a | yes |
| root\_certificate | ROOT CA used to sign service certificate | `string` | n/a | yes |
| root\_private\_key | Private key that goes with root certificate | `string` | n/a | yes |
| db\_host | Hostname of DB service | `string` | `"mysql-wso2.mysql-wso2.svc.cluster.local"` | no |
| db\_port | Port number used to acess DB service | `number` | `3306` | no |
| db\_user | User name used to access DB service | `string` | `"root"` | no |
| hostname | Hostname for WSO2 service | `string` | `"intgw"` | no |
| namespace | Kubernetes Namespace to deploy ConfigMaps and Secrets | `string` | `"wso2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate | Locally signed Server Certificate |
| fqdn | FQDN of Internal GW Service |
| helm\_status | Status of Helm deployemnt. Can be used in flow control |
| private\_key | Private key for the Server Certificate |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
