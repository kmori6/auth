variable "route_table_id" {
  description = "The route table ID."
  type        = string
}

variable "destination_cidr_block" {
  description = "The destination CIDR block for the route."
  type        = string
  default     = "0.0.0.0/0"
}

variable "gateway_id" {
  description = "The Internet Gateway ID for the route (for public subnets)."
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "The NAT Gateway ID for the route (for private subnets)."
  type        = string
  default     = null
}
