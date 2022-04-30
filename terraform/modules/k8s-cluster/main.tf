resource "aws_instance" "k8s-master" {
  for_each    = {for kube_ec2_config in var.master_kube_ec2_config : kube_ec2_config.ec2_ref => kube_ec2_config }
  ami           = each.value.aws_ami
  instance_type = each.value.ec2_size
  ebs_optimized = each.value.ebs_optimized
  availability_zone = each.value.availability_zone
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  iam_instance_profile = each.value.iam_profile
  key_name = each.value.ssh_key_name

  root_block_device {
    volume_type = "gp2"
    volume_size = each.value.root_volume_size
  }

  tags = merge(
    var.default_tags,
    {
      "Name"                                                            = "${var.environment}-kubernetes-master-${each.key}"
      "kubernetes.io/cluster/${var.tenant}-${var.environment}-mojaloop" = "member"
      "Role"                                                            = "master"
      "k8s-cluster"                                                     = "${var.name}"
    },
  )
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}


resource "aws_instance" "k8s-worker" {
  for_each    = {for kube_ec2_config in var.worker_kube_ec2_config : kube_ec2_config.ec2_ref => kube_ec2_config }
  ami           = each.value.aws_ami
  instance_type = each.value.ec2_size
  ebs_optimized = each.value.ebs_optimized
  availability_zone = each.value.availability_zone
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  iam_instance_profile = each.value.iam_profile
  key_name = each.value.ssh_key_name
  user_data = file("${path.module}/user-data/nfs-client.sh")

  root_block_device {
    volume_type = "gp2"
    volume_size = each.value.root_volume_size
  }

  tags = merge(
    var.default_tags,
    {
      "Name"                                                            = "${var.environment}-kubernetes-worker-${each.key}"
      "kubernetes.io/cluster/${var.tenant}-${var.environment}-mojaloop" = "member"
      "Role"                                                            = "worker"
      "k8s-cluster"                                                     = "${var.name}"
    },
  )
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    connection_strings_master = join(
      "\n",
      formatlist(
        "%s ansible_host=%s",
        [for master in aws_instance.k8s-master : master.private_dns],
        [for master in aws_instance.k8s-master : master.private_ip]
      ),
    )
    connection_strings_node = join(
      "\n",
      formatlist(
        "%s ansible_host=%s",
        [for worker in aws_instance.k8s-worker : worker.private_dns],
        [for worker in aws_instance.k8s-worker : worker.private_ip]
      ),
    )

    list_master   = join("\n", [for master in aws_instance.k8s-master : master.private_dns])
    list_node     = join("\n", [for worker in aws_instance.k8s-worker : worker.private_dns])
  })
  filename   = "${path.module}/${var.inventory_file}"
}

resource "aws_route53_record" "k8-masters" {
  for_each    = {for kube_ec2_config in var.master_kube_ec2_config : kube_ec2_config.ec2_ref => kube_ec2_config }
  zone_id = var.route53_private_zone_id
  name    = "k8-master-${var.name}-${each.key}.${var.route53_private_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.k8s-master[each.key].private_ip]
}

resource "aws_route53_record" "k8-workers" {
  for_each    = {for kube_ec2_config in var.worker_kube_ec2_config : kube_ec2_config.ec2_ref => kube_ec2_config }
  zone_id = var.route53_private_zone_id
  name    = "k8-worker-${var.name}-${each.key}.${var.route53_private_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.k8s-worker[each.key].private_ip]
}