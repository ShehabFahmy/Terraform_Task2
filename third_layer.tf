# Third Layer: Internal Load Balancer
#   Receives traffic from the proxy layer and forwards it to the backend servers (Backend Server1, Backend Server2).

#   Create a security group for the internal ALB to allow
#     traffic from the 2 proxy servers only
module "internal-alb-secgrp" {
  source       = "./Modules/security_group"
  vpc-id       = module.vpc.id
  secgrp-name  = "internal-app-lb-secgrp"
  created-by   = var.me
  ingress-data = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [], security_groups = [module.proxy-secgrp.id] }]
  egress-data  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

#   Create the ALB
module "internal-alb" {
  source          = "./Modules/load_balancer"
  lb-name         = "Internal-ALB"
  is-internal     = true
  lb-type         = "application"
  security-groups = [module.internal-alb-secgrp.id]
  subnets         = [module.pv-subnet1.id, module.pv-subnet2.id]
  #   Create the target group which defines where
  #     the load balancer forwards incoming traffic.
  target-grp-name     = "internal-alb-tg"
  target-grp-port     = 80     # port and
  target-grp-protocol = "HTTP" # protocol used to communicate with the targets.
  vpc-id              = module.vpc.id
  #   Create the listener which controls how the load balancer forwards traffic.
  listener-port     = 80
  listener-protocol = "HTTP"
  #   Attach the targets (EC2) with the target group
  targets = [
    #   target_port: This is the port on the specific target
    #     (e.g. EC2 instance) that overrides the default port
    #     defined in the target group.
    { target_id = aws_instance.backend-server1.id, target_port = 80 },
    { target_id = aws_instance.backend-server2.id, target_port = 80 }
  ]
}