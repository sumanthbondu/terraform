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
   Name = "Project VPC"
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

