data "aws_availability_zones" "all" {

}

provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ansible-vpc"
  }
}

# Declare the Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  #map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Replace with your desired AZ
  tags = {
    Name = "ansible-private-subnet"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  #map_public_ip_on_launch = true
  availability_zone       = "us-east-1b" # Replace with your desired AZ
  tags = {
    Name = "ansible-public-subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ansible_sg" {
  name        = "ansible-sg"
  description = "Allow SSH and other required traffic"
  vpc_id      = aws_vpc.main.id
  #http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP for ping within the VPC
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
   from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ansible_key" {
  key_name   = "ansible-key"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
}

#to connect with clients
resource "aws_key_pair" "ansible_key1" {
  key_name   = "ansible-key1"
  public_key = file("~/.ssh/ansible_key.pub")
}


resource "aws_instance" "ansible_server" {
  #  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  ami           = "ami-0885b1f6bd170450c" #ubu 24lts
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.ansible_sg.id]
  key_name      = aws_key_pair.ansible_key.key_name
  associate_public_ip_address = "true"
  tags = {
    Name = "ansible-server"
  }

  user_data = <<-EOF
  #!/bin/bash
  set -x
  # copy ssh keys make it owned and readable only to ubuntu
  mkdir -p /home/ubuntu/.ssh
  echo "${file(var.ansible_private_key_file)}" > /home/ubuntu/.ssh/ansible_key
  echo "${file(var.ansible_public_key_file)}" > /home/ubuntu/.ssh/ansible_key.pub
  chmod 600 /home/ubuntu/.ssh/ansible_key
  chown -R ubuntu:ubuntu /home/ubuntu/.ssh
  
  # Update and install required packages
  apt-get update -y
  #apt-get upgrade -y

  # Install Ansible
  # apt-get install -y software-properties-common
  # add-apt-repository --yes --update ppa:ansible/ansible
  apt-get install -y ansible

  # Add Ansible inventory directory and default hosts file
  mkdir -p /home/ubuntu/ansible
  chown ubuntu:ubuntu /home/ubuntu/ansible

  EOF

}

resource "aws_instance" "client_nodes" {
  count         = 2
  ami           = "ami-0885b1f6bd170450c" # ubu
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.ansible_sg.id]
  key_name      = aws_key_pair.ansible_key.key_name
  associate_public_ip_address = "true"
  tags = {
    Name = "ansible-client-${count.index + 1}"
  }

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/.ssh
    echo "${file(var.ansible_public_key_file)}" >> /home/ubuntu/.ssh/authorized_keys
    chmod 600 /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
  EOF
}
