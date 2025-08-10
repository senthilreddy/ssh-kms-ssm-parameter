variable "vpc_id" {
  type = string
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
