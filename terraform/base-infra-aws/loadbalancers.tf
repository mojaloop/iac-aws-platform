locals {
  name = "${var.client}-${var.environment}"
}

resource "aws_eip" "nlb" {
  for_each = {
    for az in local.availability_zones : local.public_subnet_ids["${var.environment}-${az}"]["id"] => local.public_subnet_ids["${var.environment}-${az}"]
  }
  tags = merge({ Name = "${local.name}-eip-${each.key}" }, local.default_tags)
}

resource "aws_lb" "internal-lb" { #  for internal traffic, including kube traffic
  name               = "${local.name}-internal"
  internal           = true
  load_balancer_type = "network"
  enable_cross_zone_load_balancing = true
  subnets            = [for az in local.availability_zones : local.private_subnet_ids["${var.environment}-${az}"]["id"]]
  tags = merge({ Name = "${local.name}-internal" }, local.default_tags)
}

resource "aws_lb" "external-lb" {
  name               = "${local.name}-public"
  internal           = false
  load_balancer_type = "network"
  enable_cross_zone_load_balancing = true
  tags = merge({ Name = "${local.name}-public" }, local.default_tags)
  dynamic subnet_mapping {
    for_each = { 
      for az in local.availability_zones : local.public_subnet_ids["${var.environment}-${az}"]["id"] => local.public_subnet_ids["${var.environment}-${az}"]
    }
    content {
      subnet_id = subnet_mapping.key
      allocation_id = aws_eip.nlb[subnet_mapping.key].id
    }
  }
}

resource "aws_lb_listener" "internal-port_443" {
  load_balancer_arn = aws_lb.internal-lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-31443.arn
  }
}

resource "aws_lb_target_group" "internal-31443" {
  port     = 31443
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
  target_type          = "instance"
  deregistration_delay = 90
  preserve_client_ip = false
  proxy_protocol_v2 = false

  health_check {
    interval            = 10
    port                = 31443
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.name}-aws_lb_target_group-internal-31443" }, local.default_tags)
}

resource "aws_lb_listener" "internal-port_80" {
  load_balancer_arn = aws_lb.internal-lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-31080.arn
  }
}

resource "aws_lb_target_group" "internal-31080" {
  port     = 31080
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
  target_type          = "instance"
  deregistration_delay = 90
  preserve_client_ip = false
  proxy_protocol_v2 = false

  health_check {
    interval            = 10
    port                = 31080
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.name}-aws_lb_target_group-internal-31080" }, local.default_tags)
}

resource "aws_lb_listener" "internal-port_6443" {
  load_balancer_arn = aws_lb.internal-lb.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-6443.arn
  }
}

resource "aws_lb_target_group" "internal-6443" {
  port     = 6443
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
  target_type          = "instance"
  deregistration_delay = 90
  preserve_client_ip = false
  proxy_protocol_v2 = false

  health_check {
    interval            = 10
    port                = 6443
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.name}-aws_lb_target_group-internal-6443" }, local.default_tags)
}

resource "aws_lb_listener" "external-port_443" {
  load_balancer_arn = aws_lb.external-lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-32443.arn
  }
}

resource "aws_lb_target_group" "external-32443" {
  port     = 32443
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
  target_type          = "instance"
  deregistration_delay = 90
  preserve_client_ip = true
  proxy_protocol_v2 = true

  health_check {
    interval            = 10
    port                = 32443
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.name}-aws_lb_target_group-external-32443" }, local.default_tags)
}

resource "aws_lb_listener" "external-port_80" {
  load_balancer_arn = aws_lb.external-lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-32080.arn
  }
}

resource "aws_lb_target_group" "external-32080" {
  port     = 32080
  protocol = "TCP"
  vpc_id   = data.aws_vpc.selected.id
  target_type          = "instance"
  deregistration_delay = 90
  preserve_client_ip = true
  proxy_protocol_v2 = true

  health_check {
    interval            = 10
    port                = 32080
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = merge({ Name = "${local.name}-aws_lb_target_group-external-32080" }, local.default_tags)
}
resource "aws_lb_target_group_attachment" "internal-31443" {
  for_each = {
    for i, worker in module.k8s-cluster-main.worker_nodes : i => worker.id
  }
  target_group_arn = aws_lb_target_group.internal-31443.arn
  target_id = each.value
}
resource "aws_lb_target_group_attachment" "external-32443" {
  for_each = {
    for i, worker in module.k8s-cluster-main.worker_nodes : i => worker.id
  }
  target_group_arn = aws_lb_target_group.external-32443.arn
  target_id = each.value
}
resource "aws_lb_target_group_attachment" "internal-31080" {
  for_each = {
    for i, worker in module.k8s-cluster-main.worker_nodes : i => worker.id
  }
  target_group_arn = aws_lb_target_group.internal-31080.arn
  target_id = each.value
}
resource "aws_lb_target_group_attachment" "external-32080" {
  for_each = {
    for i, worker in module.k8s-cluster-main.worker_nodes : i => worker.id
  }
  target_group_arn = aws_lb_target_group.external-32080.arn
  target_id = each.value
}
resource "aws_lb_target_group_attachment" "internal-6443" {
  for_each = {
    for i, master in module.k8s-cluster-main.master_nodes : i => master.id
  }
  target_group_arn = aws_lb_target_group.internal-6443.arn
  target_id = each.value
}