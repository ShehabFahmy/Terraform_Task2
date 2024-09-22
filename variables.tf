variable "region" {
  type    = string
  default = "us-east-1"
}

variable "s3-bucket-name" {
  type    = string
  default = "devops-tf-task2-bucket"
}

variable "me" {
  type    = string
  default = "Shehab"
}

variable "create-instance-for-ami" {
  description = "Boolean variable to invoke temporary instance creation or deletion."
  type        = bool
  default     = true
}

variable "nginx-installation" {
  default = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo service nginx start
              EOF
}

data "http" "my-public-ip" {
  url = "http://checkip.amazonaws.com"
}
