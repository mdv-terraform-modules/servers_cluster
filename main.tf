#========================= Launch Configuration ===========================

resource "aws_launch_configuration" "lc" {
  count                       = length(var.user_data)
  name_prefix                 = "LC-"
  image_id                    = data.aws_ami.latest_amazon_linux_ami.id
  instance_type               = var.environment == "Production" ? var.instance_type_prod : var.instance_type
  security_groups             = [aws_security_group.servers_sg.id]
  associate_public_ip_address = true
  user_data                   = var.environment == "Production" ? file("${path.module}/prod_user_data/${var.user_data[count.index]}_data.sh") : file("${path.module}/user_data/${var.user_data[count.index]}_data.sh")


  lifecycle {
    create_before_destroy = true
  }
}

#======================== Autoscaling Group =============================

resource "aws_autoscaling_group" "web_asg" {
  count                = length(var.user_data)
  name                 = "ASG-${aws_launch_configuration.lc[count.index].name}"
  launch_configuration = aws_launch_configuration.lc[count.index].name
  target_group_arns    = [var.target_groups_arn[count.index]]
  min_size             = var.min_size
  max_size             = var.max_size
  health_check_type    = "ELB"
  min_elb_capacity     = var.min_elb_capacity
  vpc_zone_identifier  = var.public_subnets_ids

  dynamic "tag" {
    for_each = {
      Name       = "${var.environment}-${var.user_data[count.index]}-server created by ASG"
      Owner      = var.owner
      Powered_by = var.powered_by
      Warning    = var.warning
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#============================= Security Group ==================================

resource "aws_security_group" "servers_sg" {
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.environment == "Production" ? var.ingress_ports_prod : var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = local.http_protocol
      cidr_blocks = local.any_cidr_block
    }
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.any_cidr_block
  }

  tags = merge(var.tags, { Name = "${var.environment} Security Group for cluster" })
}
