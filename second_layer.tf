# Second Layer: Proxy Layer (Proxy1, Proxy2)
#   Acts as intermediaries between the external load balancer and the internal load balancer.

#   Create a security group for the proxy servers to allow
#     traffic from the external load balancer only by adding
#     the load balancer's security group to the ingress rule.
module "proxy-secgrp" {
  source      = "./Modules/security_group"
  secgrp-name = "Proxy-Security-Group"
  created-by  = var.me
  vpc-id      = module.vpc.id
  ingress-data = [
    # VERY IMPORTANT: You have to allow SSH for the remote-exec connection and the cidr block should only be your local machine's public IP.
    #   To get the public IP we will use a data block at `variables.tf` that executes a URL of an API that replies with the IP.
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["${trimspace(data.http.my-public-ip.response_body)}/32"], security_groups = [] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [], security_groups = [module.external-alb-secgrp.id] }
  ]
  egress-data = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

module "proxy1-ec2" {
  source                 = "./Modules/aws_linux_ec2_remote_exec"
  aws-linux-instance-ami = "ami-066784287e358dad1"
  instance-type          = "t2.micro"
  key-name               = module.key-pair.key-name
  private-key-path       = module.key-pair.private-key-path
  is-public              = true
  subnet-id              = module.pb-subnet1.id
  secgrp-id              = module.proxy-secgrp.id
  remote-exec-inline     = <<-EOF
    #!/bin/bash
    ${var.nginx-installation}
    echo "Hello From Proxy1 Instance!" | sudo tee /usr/share/nginx/html/index.html
    sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null <<EOT
server {
    listen 80;

    location / {
        proxy_pass http://${module.internal-alb.dns-name};
    }
}
EOT
    sudo service nginx restart
    EOF
  tags = {
    Name       = "proxy1-nginx-instance"
    Created_by = var.me
    Is_public  = "true" # VERY IMPORTANT: used in `outputs.tf` to output the public ip
  }
}

module "proxy2-ec2" {
  source                 = "./Modules/aws_linux_ec2_remote_exec"
  aws-linux-instance-ami = "ami-066784287e358dad1"
  instance-type          = "t2.micro"
  key-name               = module.key-pair.key-name
  private-key-path       = module.key-pair.private-key-path
  is-public              = true
  subnet-id              = module.pb-subnet2.id
  secgrp-id              = module.proxy-secgrp.id
  remote-exec-inline     = <<-EOF
    #!/bin/bash
    ${var.nginx-installation}
    echo "Hello From Proxy2 Instance!" | sudo tee /usr/share/nginx/html/index.html
    # /dev/null to not print the file contents
    sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null <<EOT
server {
    listen 80;

    location / {
        proxy_pass http://${module.internal-alb.dns-name};
    }
}
EOT
    sudo service nginx restart
    EOF
  tags = {
    Name       = "proxy2-nginx-instance"
    Created_by = var.me
    Is_public  = "true" # VERY IMPORTANT: used in `outputs.tf` to output the public ip
  }
}