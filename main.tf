provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ec2"{
    ami = "ami-024fc608af8f886bc"
    instance_type = "t2.micro"
    #security_groups = [aws.aws_security_group.webtraffic.name]
}

resource "aws_eip" "elasticip"{
    instance = aws_instance.ec2.id
}

output "EIP"{
    value = aws_eip.elasticip.public_ip
}

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "Terraform VPC"
 }
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_subnet" "public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.main.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.main.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "Project VPC IG"
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "2nd Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_eks_cluster" "my_cluster" {
  cluster_name = local.cluster_name
  cluster_version = "1.24"
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.private_subnets.id
  cluster_endpoint_public_access = true
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["t2.micro"]
      min_size = 1
      max_size = 3
      desired_size = 2
    }
    two = {
      name = "node-group-2"
      instance_types = ["t2.micro"]
      min_size = 1
      max_size = 2
      desired_size = 1
    }
  }
}
