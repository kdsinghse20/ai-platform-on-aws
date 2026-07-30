variable "aws_region" {
  default = "ap-south-1"
}
variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}
