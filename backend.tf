# Backend Servers

# Create a security group to allow traffic from the internal ALB only
module "backend-secgrp" {
  source       = "./Modules/security_group"
  secgrp-name  = "Backend-Security-Group"
  created-by   = var.me
  vpc-id       = module.vpc.id
  ingress-data = [{ from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [], security_groups = [module.internal-alb-secgrp.id] }]
  egress-data  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

# To install Nginx on a private instance you can:
# 1) Attach a NAT Gateway (Free Tier Ineligible)
# 2) Create an AMI of Nginx for the backend servers
#     (Good for auto-scaling groups)
# 3) Use a Bastion Host
# 4) Use SSM Manager
# We will choose the 2nd method

module "backend-ami" {
  source                  = "./Modules/ami_from_instance"
  ami-name                = "nginx-ami"
  created-by              = var.me
  snapshot-without-reboot = true
  create-instance         = var.create-instance-for-ami # VERY IMPORTANT: true=create, false=destroy
  ec2-key-name            = module.key-pair.key-name
  ec2-key-path            = module.key-pair.private-key-path
  ec2-remote-exec-inline  = var.nginx-installation
}

resource "aws_instance" "backend-server1" {
  ami                    = module.backend-ami.ami-id
  instance_type          = "t2.micro"
  key_name               = module.key-pair.key-name
  subnet_id              = module.pv-subnet1.id
  vpc_security_group_ids = [module.backend-secgrp.id]
  user_data              = <<-EOF
    #!/bin/bash
    echo "Hello From Backend Server1 Instance!" | sudo tee /usr/share/nginx/html/index.html
    sudo service nginx restart
  EOF
  tags = {
    Name       = "backend-nginx-server1"
    Created_by = var.me
    Is_public  = "false"
  }
}

resource "aws_instance" "backend-server2" {
  ami                    = module.backend-ami.ami-id
  instance_type          = "t2.micro"
  key_name               = module.key-pair.key-name
  subnet_id              = module.pv-subnet2.id
  vpc_security_group_ids = [module.backend-secgrp.id]
  user_data              = <<-EOF
    #!/bin/bash
    echo "Hello From Backend Server2 Instance!" | sudo tee /usr/share/nginx/html/index.html
    sudo service nginx restart
  EOF
  tags = {
    Name       = "backend-nginx-server2"
    Created_by = var.me
    Is_public  = "false"
  }
}