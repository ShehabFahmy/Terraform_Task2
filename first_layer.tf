# First Layer: External Load Balancer
#   Receives traffic from the internet and distributes it to Proxy1 and Proxy2.

#   Create a security group for the External ALB to allow any traffic from the internet
module "external-alb-secgrp" {
  source       = "./Modules/security_group"
  vpc-id       = module.vpc.id
  secgrp-name  = "external-app-lb-secgrp"
  created-by   = var.me
  ingress-data = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }]
  egress-data  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

#   Create the ALB
module "external-alb" {
  source          = "./Modules/load_balancer"
  lb-name         = "External-ALB"
  is-internal     = false # Set to false for public access
  lb-type         = "application"
  security-groups = [module.external-alb-secgrp.id]
  subnets         = [module.pb-subnet1.id, module.pb-subnet2.id]
  #   Create the target group which defines where
  #     the load balancer forwards incoming traffic.
  target-grp-name     = "external-alb-tg"
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
    { target_id = module.proxy1-ec2.id, target_port = 80 },
    { target_id = module.proxy2-ec2.id, target_port = 80 }
  ]
}