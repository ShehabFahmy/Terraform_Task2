resource "aws_lb" "app_lb" {
  name               = var.lb-name
  internal           = var.is-internal
  load_balancer_type = var.lb-type
  security_groups    = var.security-groups
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name     = var.target-grp-name
  port     = var.target-grp-port
  protocol = var.target-grp-protocol
  vpc_id   = var.vpc-id
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.listener-port
  protocol          = var.listener-protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  count = length(var.targets)
  target_id        = var.targets[count.index].target_id
  port             = var.targets[count.index].target_port
}
