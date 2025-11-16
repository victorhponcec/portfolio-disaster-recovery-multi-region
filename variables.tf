variable "region1" {
  description = "main region"
  type        = string
  default     = "us-east-1"
}

variable "region2" {
  description = "main region"
  type        = string
  default     = "us-west-1"
}

variable "az1" {
  description = "availability zone 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "availability zone 2"
  type        = string
  default     = "us-east-1b"
}

variable "az1_r2" {
  description = "availability zone 1"
  type        = string
  default     = "us-west-1a"
}

variable "az2_r2" {
  description = "availability zone 2"
  type        = string
  default     = "us-west-1b"
}

variable "email" {
  description = "email for sns"
  default     = "victortest@gmail.com"
}

variable "on-prem-vpn" {
  description = "on-premise vpn range"
  default     = "0.0.0.0/0"
}

variable "domain" {
  description = "main domain"
  default     = "victorponce.site"
}

variable "amazon_linux_2023" {
  description = "Amazon Linux 2023"
  default = "ami-05576a079321f21f8"
}