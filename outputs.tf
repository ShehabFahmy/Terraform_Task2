# resource "local_file" "vpc-id-output" {
# 	content = module.vpc.id
# 	filename = "vpc-id-output.txt"
# }

# resource "local_file" "proxy1-ec2-ip-output" {
# 	content = module.proxy1-ec2.public-ip
# 	filename = "proxy1-ec2-ip-output.txt"
# }

# resource "local_file" "proxy2-ec2-ip-output" {
# 	content = module.proxy2-ec2.public-ip
# 	filename = "proxy2-ec2-ip-output.txt"
# }

data "aws_instances" "my-public-instances" {
  filter {
    name   = "tag:Is_public"
    values = ["true"]
  }
}

resource "null_resource" "output-public-ip" {
  count = length(data.aws_instances.my-public-instances.public_ips)
  provisioner "local-exec" {
    command     = "echo public-ip${count.index + 1}: ${data.aws_instances.my-public-instances.public_ips[count.index]} >> all-ips.txt"
    working_dir = path.cwd
  }
}

output "external-alb-dns" {
  value       = module.external-alb.dns-name
  description = "The DNS name of the External Load Balancer"
}

resource "local_file" "dns-output-file" {
  content  = module.external-alb.dns-name
  filename = "dns-output.txt"
}
