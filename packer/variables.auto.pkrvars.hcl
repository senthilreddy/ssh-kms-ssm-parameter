aws_region      = "ap-south-1"
instance_type   = "t2.micro"
ami_name        = "fedora-ami-{{timestamp}}"
ssh_username    = "fedora"
source_ami      = "ami-0ed5080902313ab90"
ami_description = "Fedora Base AMI"
tags = {
  Name        = "FedoraAMI"
  Environment = "Dev"
}
