variable "allocation_id" {
  description = "The Allocation ID of the Elastic IP address for the NAT Gateway."
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID of the subnet in which to place the NAT Gateway."
  type        = string
}

variable "name" {
  description = "The name tag for the NAT Gateway."
  type        = string
}
