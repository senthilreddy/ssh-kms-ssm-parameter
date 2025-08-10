variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "sg_name_vpn" {
  type    = string
  default = "vpn-ssh-sg"
}

variable "sg_name_private" {
  type    = string
  default = "private-instance-sg"
}

variable "vpn_udp_port" {
  type    = number
  default = 1194
}

variable "vpn_tcp_port" {
  type    = number
  default = 0
}

variable "vpn_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ssh_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
