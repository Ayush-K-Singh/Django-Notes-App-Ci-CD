provider "aws" {
  region = "eu-north-1"
  access_key = "AKIAXYXAOW7D6MBMMGMV"
  secret_key = "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"
}

variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_cidr_block {
    default = "10.0.0.0/24"
}
variable availability_zone {
    default = "eu-north-1a"
}
# variable public_key_location {}

resource "aws_vpc" "deployment-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "deployment-vpc-cicd"
  }
}

resource "aws_subnet" "deployment-subnet" {
  vpc_id     = aws_vpc.deployment-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name: "deployment-subnet-cicd"
  }
}

resource "aws_internet_gateway" "deployment-igw" {
  vpc_id = aws_vpc.deployment-vpc.id

  tags = {
    Name = "deployment-igw-cicd"
  }
}

resource "aws_route_table" "deployment-routetable" {
  vpc_id = aws_vpc.deployment-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deployment-igw.id
  }

  tags = {
    Name = "deployment-routetable-cicd"
  }
}

resource "aws_route_table_association" "deployment-rta" {
  subnet_id      = aws_subnet.deployment-subnet.id
  route_table_id = aws_route_table.deployment-routetable.id
}

resource "aws_security_group" "deployment-securitygroup" {
  name        = "deployment-securitygroup-name"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.deployment-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "deployment-securitygroup-cicd"
  }
}

data "aws_ami" "deployment-amazon-linux-2" {
  most_recent = true
  owners = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.deployment-amazon-linux-2.id
}

output "aws_ec2_instance_ip" {
  value = aws_instance.deployment-ec2-instance.public_ip
}

# resource "aws_key_pair" "deployment-keypair" {
#   key_name   = "deployment-keypair-cicd"
#   public_key = file("id_rsa.pub")
# }

resource "aws_instance" "deployment-ec2-instance" {
  ami           = data.aws_ami.deployment-amazon-linux-2.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.deployment-subnet.id
  vpc_security_group_ids = [aws_security_group.deployment-securitygroup.id]
  availability_zone = var.availability_zone

  associate_public_ip_address = true
  key_name = "AWS-KeyPair"

  user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install docker -y
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                    sudo chmod +x /usr/local/bin/docker-compose
                EOF

  tags = {
    Name = "deployment-ec2-instance-cicd"
  }
}