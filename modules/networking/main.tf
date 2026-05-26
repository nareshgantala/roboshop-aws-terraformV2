resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block,8,count.index+2)
  availability_zone   = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet_${count.index+1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block,8,count.index+10)
  availability_zone   = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private_subnet_${count.index+1}"
  }
}



resource "aws_route_table" "main_gw" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }

  tags = {
    Name = "roboshop-rt"
  }
}



resource "aws_route_table_association" "main" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.main_gw.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "roboshop-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}


resource "aws_route_table" "main_nat" {
        vpc_id = var.vpc_id

        route {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = aws_nat_gateway.main.id
        }

        tags = {
            Name = "roboshop-nat-rt"
  }
  
}

resource "aws_route_table_association" "main_nat" {
  count = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.main_nat.id
}


