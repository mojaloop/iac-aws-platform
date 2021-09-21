resource "aws_instance" "k8s-master" {
  ami           = var.aws_ami
  instance_type = var.kube_master_size

  count         = var.kube_master_num
  ebs_optimized = var.kube_master_ebs_optimized

  availability_zone = var.availability_zone

  subnet_id = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.kubemaster_iam_profile

  key_name = var.ssh_key_name

  root_block_device {
    volume_type = "gp2"
    volume_size = var.master_root_volume_size
  }

  tags = merge(
    var.default_tags,
    {
      "Name"                                                            = "${var.environment}-kubernetes-master${count.index}"
      "kubernetes.io/cluster/${var.tenant}-${var.environment}-mojaloop" = "member"
      "Role"                                                            = "master"
      "k8s-cluster"                                                     = "${var.name}"
    },
  )
}


resource "aws_instance" "k8s-worker" {
  ami           = var.aws_ami
  instance_type = var.kube_worker_size

  count         = var.kube_worker_num
  ebs_optimized = var.kube_worker_ebs_optimized

  availability_zone = var.availability_zone

  subnet_id = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.kubeworker_iam_profile

  #iam_instance_profile = module.aws-iam.kube-worker-profile
  key_name  = var.ssh_key_name
  user_data = file("${path.module}/user-data/nfs-client.sh")
  root_block_device {
    volume_type = "gp2"
    volume_size = var.master_root_volume_size
  }

  tags = merge(
    var.default_tags,
    {
      "Name"                                                            = "${var.environment}-kubernetes-worker${count.index}"
      "kubernetes.io/cluster/${var.tenant}-${var.environment}-mojaloop" = "member"
      "Role"                                                            = "worker"
      "k8s-cluster"                                                     = "${var.name}"
    },
  )
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = var.ebs_device_name
  count       = var.kube_worker_num
  volume_id   = aws_ebs_volume.slowfs[count.index].id
  instance_id = aws_instance.k8s-worker[count.index].id
}


resource "aws_ebs_volume" "slowfs" {
  count             = var.kube_worker_num
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
}

resource "aws_instance" "haproxy" {
  count         = var.haproxy_enabled ? 1 : 0
  ami           = var.aws_ami
  instance_type = var.haproxy_size

  availability_zone = var.availability_zone

  subnet_id = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  key_name = var.ssh_key_name
  tags = merge(
    var.default_tags,
    {
      Name = "haproxy-${var.name}"
    }
  )
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    connection_strings_master = join(
      "\n",
      formatlist(
        "%s ansible_host=%s",
        aws_instance.k8s-master.*.private_dns,
        aws_instance.k8s-master.*.private_ip
      ),
    )
    connection_strings_node = join(
      "\n",
      formatlist(
        "%s ansible_host=%s",
        aws_instance.k8s-worker.*.private_dns,
        aws_instance.k8s-worker.*.private_ip,
      ),
    )

    list_master   = join("\n", aws_instance.k8s-master.*.private_dns)
    list_node     = join("\n", aws_instance.k8s-worker.*.private_dns)
  })
  filename   = "${path.root}/${var.inventory_file}"
}

resource "aws_route53_record" "k8-masters" {
  count   = var.kube_master_num
  zone_id = var.route53_private_zone_id
  name    = "k8-master-${var.name}-${count.index}.${var.route53_private_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.k8s-master.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "k8-workers" {
  count = var.kube_worker_num

  zone_id = var.route53_private_zone_id
  name    = "k8-worker-${var.name}-${count.index}.${var.route53_private_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.k8s-worker.*.private_ip, count.index)]
}

resource "aws_route53_record" "k8-haproxy" {
  count   = var.haproxy_enabled ? length(var.haproxy_aliases) : 0

  zone_id = var.route53_private_zone_id
  name    = "${var.haproxy_aliases[count.index]}.${var.route53_private_zone_name}"
  type    = "A"
  ttl     = "300"
  records = aws_instance.haproxy.*.private_ip
}
