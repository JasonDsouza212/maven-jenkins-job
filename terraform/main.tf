provider "aws" {
    region = "ap-south-1"
}

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
    default = "122.171.18.254/32" 
}
variable "jenkins_ip" {
    default = "122.171.17.217/32"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "region" {
  default="ap-south-1a"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags ={
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id =aws_vpc.myapp-vpc.id
  tags={
    Name:"${var.env_prefix}-igw"
  }
}
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id=aws_vpc.myapp-vpc.default_route_table_id    
    route{
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id 
  }
  tags={
    Name:"${var.env_prefix}-main-rtb"
  }
}
resource "aws_default_security_group" "default-myapp-sg" {
  vpc_id= aws_vpc.myapp-vpc.id

  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

   ingress{
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
     prefix_list_ids = []
  }
    tags={
    Name:"${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values=["amzn2-ami-kernel-*-x86_64-gp2"]
  }
    filter {
    name="virtualization-type"
    values=["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
  ami                           = data.aws_ami.latest-amazon-linux-image.id
  instance_type                 = var.instance_type

  subnet_id                     = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids        = [ aws_default_security_group.default-myapp-sg.id ]
  availability_zone             = var.avail_zone

  associate_public_ip_address   = true
  
  key_name                      = "my-app-key-pair"

  tags={
    Name:"${var.env_prefix}-server"
  }
}

output "aws_public_ip" {
  value = aws_instance.myapp-server.public_ip
}