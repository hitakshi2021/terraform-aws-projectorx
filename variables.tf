variable "aws_region" {
    description = "AWS deployment region"
    type = string
    default = "ap-south-1"
}

variable "instance_type" {
    description = "AWS instance"
    type = string
    default = "t2.micro"
}

variable "server_name" {
    description = "AWS instance name"
    type = string
    default = "my_vm1"   
}