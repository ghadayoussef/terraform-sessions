variable "region" {
  type        = string
  description = "value"
  default     = "eu-central-1"
}

variable "name_prefix" {
  type        = string
  description = "name prefix for resources"
  default     = "civic"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
  default     = "10.42.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "vpc cidr"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "cidrs for public subnets"
  default     = ["10.42.1.0/24", "10.42.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "cidrs for public subnets"
  default     = ["10.42.11.0/24", "10.42.12.0/24"]
}

variable "create_nat_per_az" {
  type        = bool
  description = "create nat per az true (multiple) or (nat) single"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "tags for resources"
  default     = {}
}