packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.0"
    }
  }
}

variable "aws_region"      { type = string }
variable "instance_type"   { type = string }
variable "ami_name"        { type = string }
variable "ssh_username"    { type = string }
variable "source_ami"      { type = string }
variable "ami_description" { type = string }
variable "tags"            { type = map(string) }

source "amazon-ebs" "base" {
  region         = var.aws_region
  instance_type  = var.instance_type
  ssh_username   = var.ssh_username
  source_ami     = var.source_ami
  ami_name       = var.ami_name
  ami_description= var.ami_description
  tags           = var.tags
  ssh_timeout    = "10m"
}

build {
  sources = ["source.amazon-ebs.base"]
  provisioner "ansible" {
    playbook_file = "../ansible/common.yml"
  }
}
