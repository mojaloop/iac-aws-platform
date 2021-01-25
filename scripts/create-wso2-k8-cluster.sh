#!/usr/bin/env bash
#./haproxy-secured-wso2.sh

ansible-playbook -i ./inventory/hosts-gateway ./cluster.yml \
  -e "@${PWD}/../scripts/extra-vars.json" \
  -e "kube_proxy_mode=iptables artifacts_dir=inventory/artifacts/gateway" \
  -e "cloud_provider=aws ansible_user=ubuntu" \
  -b --become-user=root --flush-cache

cp inventory/artifacts/gateway/admin.conf ../admin-gateway.conf
