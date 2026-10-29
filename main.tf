terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
        Name = "ProjectorX-VPC"
    }
}

resource "aws_subnet" "my_public_subent" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1a"
    
    tags = {
        Name = "public-subnet-1"
    }
}

resource "aws_internet_gateway" "my_gwt" {
    vpc_id = aws_vpc.my_vpc.id
    
    tags = {
        Name = "projectorx-IGW"
    }
}

resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_gwt.id
    }
    tags = {
        Name = "My route table"
    }
}

resource "aws_route_table_association" "my_routetable" {
    subnet_id = aws_subnet.my_public_subent.id
    route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_sg" {
    name = "projectorx_sg"
    description = "allow ssh and https inbound traffic"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
        Name = "Projectorx-SG"
    }

}

resource "aws_instance" "my_vm" {
    ami = "ami-022374b883d9d7931"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.my_public_subent.id
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    tags = {
        Name = var.server_name
        Enviournemnt = "Learning"
    }
    
}


resource "aws_s3_bucket" "my_bucket" {
  bucket = "hitakshi-terraform-practical-bucket-2026-unique" 

  tags = {
    Name        = "Practical S3 Bucket"
    Environment = "Learning"
  }
}

output "server_public_ip" {
  value       = aws_instance.my_vm.public_ip
  description = "Public IP address of EC2 instance"
}

output "s3_bucket_id" {
  value       = aws_s3_bucket.my_bucket.id
  description = "Name/ID of the created S3 bucket"
}

output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "The ID of the VPC"
}