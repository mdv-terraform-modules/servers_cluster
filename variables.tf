variable "user_data" {}
variable "environment" {}
variable "target_groups_arn" {}
variable "public_subnets_ids" {}
variable "owner" {}
variable "powered_by" {}
variable "warning" {}
variable "vpc_id" {}
variable "tags" {}
variable "min_size" {}
variable "max_size" {}
variable "min_elb_capacity" {}

variable "ingress_ports" {
  default = ["22", "80", "443", "8888", ]
}
variable "ingress_ports_prod" {
  default = ["80", "443", "8888", ]
}
variable "instance_type" {
  default = "t2.micro"
}
variable "instance_type_prod" {
  default = "t3.micro"
}
locals {
  any_cidr_block = ["0.0.0.0/0"]
  any_protocol   = "-1"
  http_protocol  = "tcp"
  any_port       = 0
}
