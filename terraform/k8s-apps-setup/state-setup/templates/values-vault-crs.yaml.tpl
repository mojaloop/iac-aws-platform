secretName: ${secret_name}
namespace: ${namespace}
resourceType: ${resource_type}
authPath: ${auth_path}
authRole: ${auth_role}
authSvcAcct: ${auth_svc_acct}
vaultBasePath: ${vault_base_path}
resourceName: ${resource_name}
secretNamespaces: ${secret_namespaces}
secretKeyMap:
%{ for key, value in secret_keys_map ~}
  ${key}: ${value}
%{ endfor ~}
secretPasswordPolicy: |
  ${indent(2, secret_password_policy)}