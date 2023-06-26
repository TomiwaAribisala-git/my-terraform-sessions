provider "aws" {}

resource "aws_vpc" "practice-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "practice-vpc"
    }
}

resource "aws_subnet" "practice-subnet-1" { 
    vpc_id = aws_vpc.practice-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "practice-subnet-1"
    }
}

resource "aws_internet_gateway" "practice-gw" {
    vpc_id = aws_vpc.practice-vpc.id
    tags = {
        Name = "practice-gw"
  }
}

resource "aws_route_table" "practice-route-table" {
    vpc_id = aws_vpc.practice-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.practice-gw.id 
    }
    tags = {
        Name = "practice-route-table"
    }
}

resource "aws_route_table_association" "private-subnet-route_table_association" {
    subnet_id = aws_subnet.practice-subnet-1.id 
    route_table_id = aws_route_table.practice-route-table.id 
}

resource "aws_security_group" "private-sg" { 
    name        = "private-sg"
    vpc_id      = aws_vpc.practice-vpc.id

    ingress {
        description      = "ssh from private ip"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "user access from web interface"
        from_port        = 8080
        to_port          = 8080
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"] 
    }

    tags = {
        Name = "private-sg"
    }
}

data "aws_ami" "latest-amazon-ami-image" {
    most_recent      = true
    owners           = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "private-instance" {
    ami                     = data.aws_ami.latest-amazon-ami-image.id 
    instance_type           = "t2.micro"
    subnet_id = aws_subnet.practice-subnet-1.id 

    vpc_security_group_ids = [aws_security_group.private-sg.id] 

    availability_zone = var.avail_zone

    associate_public_ip_address = true

    key_name = "ec2"

    user_data = file("script.sh")

    tags = {
        Name = "private-instance"
    }
}