variable "aws_region" {
  description = "AWS region for TicketDesk infrastructure"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Prefix used for TicketDesk AWS resources"
  type        = string
  default     = "tkt-mrittika"
}

variable "vpc_cidr" {
  description = "CIDR block for the TicketDesk VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet in ap-southeast-2a"
  type        = string
  default     = "10.20.10.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet in ap-southeast-2b"
  type        = string
  default     = "10.20.20.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet in ap-southeast-2a"
  type        = string
  default     = "10.20.110.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet in ap-southeast-2b"
  type        = string
  default     = "10.20.120.0/24"
}

variable "availability_zone_1" {
  description = "First Availability Zone"
  type        = string
  default     = "ap-southeast-2a"
}

variable "availability_zone_2" {
  description = "Second Availability Zone"
  type        = string
  default     = "ap-southeast-2b"
}
variable "container_image" {
  description = "ECR image used by the TicketDesk API"
  type        = string
  default     = "243112136699.dkr.ecr.ap-southeast-2.amazonaws.com/ticketdesk:d2d1f06"
}