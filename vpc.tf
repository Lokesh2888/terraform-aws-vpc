#roboshop-dev
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

#IG roboshop-dev
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id #association with VPC

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

#roboshop-dev-us-east-1a
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "data_base" {
  count = length(var.data_base_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.data_base_subnet_cidrs[count.index]
  
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.data_base_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-data_base-${local.az_names[count.index]}"
    }
  )
}

resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_routetable_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_routetable_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route_table" "data_base" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.data_base_routetable_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "data_base" {
  route_table_id            = aws_route_table.data_base.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#associate route with subnets
resource "aws_route_table_association" "public" {
   count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data_base" {
  count = length(var.data_base_subnet_cidrs)
  subnet_id      = aws_subnet.data_base[count.index].id
  route_table_id = aws_route_table.data_base.id
}


