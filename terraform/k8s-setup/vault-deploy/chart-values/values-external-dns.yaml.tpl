provider: aws
aws:
  credentials:
    accessKey: ${external_dns_iam_access_key}
    secretKey: ${external_dns_iam_secret_key}
  region: ${region}
domainFilters:
  - ${domain}
  - ${internal_domain}
txtOwnerId: ${txt_owner_id}
policy: sync
dryRun: false
interval: 30m
triggerLoopOnEvent: true
txtPrefix: extdns