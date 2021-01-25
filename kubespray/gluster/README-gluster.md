## Kubernetes On-Prem Gluster Heketi Storage ##

Kubernetes on-premise Gluster Heketi distributed storage.

## Description ##

Setup persistent storage with Gluster and Heketi for on-prem Kubernetes clusters.

## GlusterFS Storage ##

Create a Kubernetes default storage class using the distributed filesystem GlusterFS, managed through Heketi REST API.  Providing a default storage class abstracts the application from the implementation.  Kubernetes application deployments can now claim storage without specifying what kind.

Requirement:  Additional raw physical or virtual disk.  The disk will be referenced by it's device name (i.e. _/dev/sdc_).

From the __control node__, configure hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Gluster cluster is managed by Heketi.  Raw storage volumes are defined in a topology file.

## Configure and Deploy Gluster Heketi ##

Configure the Gluster Heketi topology and deploy the distributed cluster.  This distributed filesystem exists on the Kubernetes nodes on specified disk.  It is recommended to allocate a dedicated disk on each node (i.e. /dev/sdd).


1. __GlusterFS Cluster Topology__

    a. Define Heketi GlusterFS topology.  
   
    For each node block, the `hostnames.manage` value should be set to the node _FQDN_ and the `storage` value should be set to the node _IP address_.  The raw block device(s) (i.e. _/dev/sdd_) are specified under `devices`.  See _files/topology-sample.json_ for an example of multiple block devices per node.  Additional examples in the _files_ directory.  
   
    Edit file to define distributed filesystem members.  Modify file with editor such as vi or nano.

    `$ vi ~/kubespray-and-pray/inventory/default/topology.json`   

    b. Define Kubespray inventory nodes in gluster group.
    
    _It's safe to skip this step if gluster group was already defined in inventory.cfg during Kubespray deploy, as the gluster group will already be defined_.  
    
     Edit `gluster` section in Kubespray inventory file.  Specify which nodes are to become members of the GlusterFS distributed filesystem.  Modify file with editor such as vi or nano.  Copy to _.kubespray_ directory.

    `$ vi inventory/default/inventory.cfg`  
    `$ cp inventory/default/inventory.cfg ~/.kubespray/inventory`  

2. __Deploy Heketi GlusterFS__

    Run ansible playbook on all GlusterFS members to install kernel modules and glusterfs client.  The playbook  will be run against the `gluster` inventory group.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook gluster.yml`   
