#!/usr/bin/env bash

ansible-playbook -i ./inventory/hosts-mojaloop ./haproxy.yml \
  -e ansible_user=ubuntu -b --become-user=root --flush-cache

ansible-playbook -i ./inventory/hosts-mojaloop ./cluster.yml \
  -e "@${PWD}/../scripts/extra-vars.json" \
  -e "kube_proxy_mode=iptables artifacts_dir=inventory/artifacts/mojaloop" \
  -e "cloud_provider=aws ansible_user=ubuntu" \
  -b --become-user=root --flush-cache

cp inventory/artifacts/mojaloop/admin.conf ../admin-mojaloop.conf
