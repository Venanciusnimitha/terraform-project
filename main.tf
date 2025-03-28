#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "dev_public_subnet"
  }

}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-internet-gatewayterra"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "my-public-rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }
  tags = {
    Name = "dev-public-rt"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "my-public-rt-assoc" {
  route_table_id = aws_route_table.my-public-rt.id
  subnet_id      = aws_subnet.my_subnet.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_tls" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "allow_tls"
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0

  lifecycle {
    ignore_changes = all
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykey.pub")
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "web_node" {
  ami           = data.aws_ami.my_ami.id
  instance_type = "t2.micro"

  tags = {
    Name = "dev_node"
  }

  key_name                  = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids    = [aws_security_group.allow_tls.id]
  subnet_id                 = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
  }

  # Add the userdata correctly
  user_data = file("userdata.tpl")
  #https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
  
  # ...
  #https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax

  provisioner "local-exec" {
    command = templatefile("windows-ssh-config.tpl", { #${var.host_os}
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "C:/Users/Kaliraja/.ssh/mykey"

    })
    interpreter = ["powershell", "-Command"] #for windows
  }
}


