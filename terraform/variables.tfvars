variable "vpc_cidr_block" {
    default = "172.41.0.0/16"
}
variable "subnet_cidr_block" {
    default = "172.41.0.0/24"
}
variable "avail_zone" {
    default = "ap-south-1a"
}
variable "env_prefix" {
    default = "dev"
}
variable "my_ip" {
    default = "122.171.17.217/32" 
}
# variable "jenkins_ip" {
#     default = "122.171.17.217/32"
# }
variable "instance_type" {
    default = "t2.micro"
}
variable "region" {
  default="ap-south-1a"
}
