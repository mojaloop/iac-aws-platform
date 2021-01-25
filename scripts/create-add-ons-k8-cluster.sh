#!/usr/bin/env bash
set -e

ansible-playbook -i ./inventory/hosts-add-ons ./cluster.yml \
  -e "@${PWD}/../scripts/extra-vars.json" \
  -e "kube_proxy_mode=iptables artifacts_dir=inventory/artifacts/add-ons" \
  -e "cloud_provider=aws ansible_user=ubuntu" \
  -b --become-user=root --flush-cache

cp inventory/artifacts/add-ons/admin.conf ../admin-add-ons.conf
