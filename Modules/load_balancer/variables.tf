variable "lb-name" {
  type = string
}

variable "is-internal" {
  type = bool
}

variable "lb-type" {
  type = string
}

variable "security-groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "target-grp-name" {
  type = string
}

variable "target-grp-port" {
  type = number
}

variable "target-grp-protocol" {
  type = string  
}

variable "vpc-id" {
  type = string
}

variable "listener-port" {
  type = number
}

variable "listener-protocol" {
  type = string
}

variable "targets" {
  type = list(object({
    target_id = string
    target_port = number
  }))
}
