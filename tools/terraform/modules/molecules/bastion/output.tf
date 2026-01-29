output "bastion_instance_id" {
  description = "The ID of the bastion EC2 instance."
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "The public IP address of the bastion."
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "The ID of the bastion security group."
  value       = aws_security_group.bastion.id
}

output "ssh_command" {
  description = "SSH command to connect to bastion."
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.bastion.public_ip}"
}

output "ssm_command" {
  description = "AWS SSM command to connect to bastion."
  value       = "aws ssm start-session --target ${aws_instance.bastion.id}"
}
