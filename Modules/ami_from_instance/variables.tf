variable "created-by" {
  type = string
}

variable "ec2-key-name" {
  type = string
}

variable "ec2-key-path" {
  type = string
}

variable "ec2-remote-exec-inline" {
  type = string
}

variable "create-instance" {
  description = "Boolean variable to invoke temporary instance creation or deletion."
  type = bool
}

variable "snapshot-without-reboot" {
  type = bool
}

variable "ami-name" {
  type = string
}
