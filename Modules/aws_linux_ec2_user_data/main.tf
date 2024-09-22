# Task 1
# Create a resource of type EC2 instance and
#   of name "aws-linux-instance"
resource "aws_instance" "aws-linux-instance" {
  ami                    = var.aws-linux-instance-ami
  instance_type          = var.instance-type
  key_name               = var.key-name
  subnet_id              = var.subnet-id
  vpc_security_group_ids = [var.secgrp-id]
  # User Data to run scripts at the instance's launch
  user_data = var.user-data
  # Ensure the instance gets a public IP
  associate_public_ip_address = true

  tags = {
    Name = var.instance-name
    Created_by = var.created-by
  }
}
