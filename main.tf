provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ec2"{
    ami = "ami-024fc608af8f886bc"
    instance_type = "t2.micro"
    security_groups = [aws.aws_security_group.webtraffic.naem]
}

resource "aws_eip" "elasticip"{
    instance = aws_instance.ec2.id
}

output "EIP"{
    value = aws_eip.elasticip.public_ip
}

resource "aws_security_group" "webtraffic" {
    name = "Allow HTTPS"

    ingress{
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}.fdvdvssdv