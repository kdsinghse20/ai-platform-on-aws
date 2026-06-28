variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type = string
}

variable "key_name" {
  type = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "user_data" {
  type    = string
  default = null
}
