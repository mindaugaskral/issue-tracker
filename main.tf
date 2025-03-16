provider "aws" {
  region = "eu-central-1"
}

# 1. Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

# 2. Create a Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id  # ✅ Fixed: Correct reference, removed quotes
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"  # ✅ Ensure correct AZ in your region

  tags = {
    Name = "MySubnet"
  }
}

# 3. Create an Internet Gateway
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}

# 4. Create a Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id  # ✅ Fixed incorrect name
  }

  tags = {
    Name = "MyRouteTable"
  }
}

# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "my_route_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# 6. Create a Security Group to Allow SSH
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ WARNING: Open to all! Restrict for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

# 7. Launch an EC2 Instance
resource "aws_instance" "my_instance" {
  ami                    = "ami-07eef52105e8a2059" # "ami-00dc61b35bec09b72"  # ✅ Make sure this AMI exists in your region
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]  # ✅ Fixed security group reference
  key_name               = "raktas"  # ✅ Replace with your actual key pair name

  tags = {
    Name = "MyEC2Instance"
  }
}

# 8. Output the Public IP
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}