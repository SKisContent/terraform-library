variable "instance_name" {
  description = "The name to give to this set of resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(any)
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The VPC in which to create the resource; will use default if none is provided."
  default     = null
}

variable "ami" {
  type        = string
  description = "The AMI ID you want to use; if not provided, the latest Amazon Linux image will be used."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The subnet in which to create the instance; if blank, the first subnet from the VPC will be used."
  default     = null
}

variable "instance_type" {
  type        = string
  description = ""
}

variable "key_name" {
  default     = null
  type        = string
  description = ""
}

variable "associate_public" {
  default     = false
  type        = string
  description = ""
}

variable "user_data" {
  default     = null
  type        = string
  description = ""
}
