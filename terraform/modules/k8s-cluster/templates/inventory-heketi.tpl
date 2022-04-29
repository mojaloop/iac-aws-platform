all:
    vars:
        heketi_admin_key: "11jadjlfafladfs"
        heketi_user_key: "!!adskafdfask"
        kube_config_dir: /etc/kubernetes
        bin_dir: /usr/local/bin
    children:
        k8s-cluster:
            vars:
                kubelet_fail_swap_on: false
            children:
                kube-master:
                    hosts:
                        ${name_k8_master_0}:
                            ansible_host: ${ip_k8_master_0}
                        ${name_k8_master_1}:
                            ansible_host: ${ip_k8_master_1}
                        ${name_k8_master_2}:
                            ansible_host: ${ip_k8_master_2}
                etcd:
                    hosts:
                        ${name_k8_master_0}:
                            ansible_host: ${ip_k8_master_0}
                        ${name_k8_master_1}:
                            ansible_host: ${ip_k8_master_1}
                        ${name_k8_master_2}:
                            ansible_host: ${ip_k8_master_2}
                kube-node:
                    hosts: &kube_nodes
                        ${name_k8_worker_0}:
                            ansible_host: ${ip_k8_worker_0}
                        ${name_k8_worker_1}:
                            ansible_host: ${ip_k8_worker_1}
                        ${name_k8_worker_2}:
                            ansible_host: ${ip_k8_worker_2}
                heketi-node:
                    vars:
                        disk_volume_device_1: "/dev/xvdh"
                    hosts:
                        <<: *kube_nodes