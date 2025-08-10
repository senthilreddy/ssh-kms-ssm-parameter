output "vpn_ssh_sg_id"       { value = aws_security_group.vpn_ssh.id }
output "private_instance_sg" { value = aws_security_group.private_vm.id }
