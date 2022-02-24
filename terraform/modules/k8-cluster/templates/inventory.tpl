[all]
${connection_strings_master}
${connection_strings_node}

[kube-master]
${list_master}


[kube-node]
${list_node}


[etcd]
${list_master}

[k8s-cluster:children]
kube-node
kube-master


