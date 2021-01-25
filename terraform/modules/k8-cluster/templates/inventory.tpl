[all]
${connection_strings_master}
${connection_strings_node}
${connection_strings_balancer}

[kube-master]
${list_master}


[kube-node]
${list_node}

[gluster]
${list_node}

[etcd]
${list_master}

[balancer]
${list_balancer}

[k8s-cluster:children]
kube-node
kube-master


