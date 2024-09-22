# First: Create an EC2 instance and install Nginx on it

resource "aws_vpc" "temp-vpc" {
  count = var.create-instance ? 1 : 0
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "temp-subnet" {
  count = var.create-instance ? 1 : 0
  vpc_id                  = aws_vpc.temp-vpc[0].id
  cidr_block              = "10.0.1.0/24"
  # availability_zone       = "us-east-1a"  # Change as needed
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "temp-igw" {
  count = var.create-instance ? 1 : 0
  vpc_id = aws_vpc.temp-vpc[0].id
}

resource "aws_route_table" "temp-rtb" {
  count = var.create-instance ? 1 : 0
  vpc_id = aws_vpc.temp-vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.temp-igw[0].id
  }
}

resource "aws_route_table_association" "temp-rtb-assoc" {
  count = var.create-instance ? 1 : 0
  subnet_id      = aws_subnet.temp-subnet[0].id
  route_table_id = aws_route_table.temp-rtb[0].id
}

resource "aws_security_group" "temp-secgrp" {
  count = var.create-instance ? 1 : 0
  vpc_id = aws_vpc.temp-vpc[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "temp-ec2" {
  count = var.create-instance ? 1 : 0
  ami           = "ami-066784287e358dad1"
  instance_type = "t2.micro"
  key_name = var.ec2-key-name
  associate_public_ip_address = true
  subnet_id = aws_subnet.temp-subnet[0].id
  vpc_security_group_ids = [aws_security_group.temp-secgrp[0].id]
  # user_data = var.ec2-user-data
  provisioner "remote-exec" {
    inline = [var.ec2-remote-exec-inline]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ec2-key-path)
      host        = self.public_ip
    }
  }
  tags = {
    Name = "Temp-Nginx"
  }
}

# Second: Create the AMI
resource "aws_ami_from_instance" "nginx-ami" {
  source_instance_id = var.create-instance ? aws_instance.temp-ec2[0].id : ""
  name = var.ami-name
  snapshot_without_reboot = var.snapshot-without-reboot
  depends_on = [ aws_instance.temp-ec2 ]
  lifecycle {
    ignore_changes = [ source_instance_id ]   # VERY IMPORTANT!!: Doesn't terminate the AMI with the EC2 termination
  }
  tags = {
    Name = "Nginx-AMI"
    Created_by = var.created-by
  }
}

# Finally: Terminate the temporary instance
#   by executing `terraform apply -var="create-instance=false"`