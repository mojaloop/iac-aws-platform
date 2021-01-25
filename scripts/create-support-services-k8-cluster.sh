#!/usr/bin/env bash
set -e

ansible-playbook -i ./inventory/hosts-support-services ./haproxy.yml \
  -e ansible_user=ubuntu -b --become-user=root --flush-cache

ansible-playbook -i ./inventory/hosts-support-services ./cluster.yml \
  -e "@${PWD}/../scripts/extra-vars.json" \
  -e "kube_proxy_mode=iptables artifacts_dir=inventory/artifacts/support-services" \
  -e "cloud_provider=aws ansible_user=ubuntu" \
  -b --become-user=root --flush-cache

cp inventory/artifacts/support-services/admin.conf ../admin-support-services.conf
