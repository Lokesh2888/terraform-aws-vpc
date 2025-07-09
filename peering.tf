resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0 #if they give false the count is zero and will not be created. If they give true the count is one and will be created.
  peer_vpc_id   = data.aws_vpc.default.id #Accepter VPC is default here.Need to mention .id to get default VPC
  vpc_id        = aws_vpc.main.id #requester

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-default"
    }
  )
}

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0 
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0 
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "data_base_peering" {
  count = var.is_peering_required ? 1 : 0 
  route_table_id            = aws_route_table.data_base.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#we should add peering connection in default VPC main route table too

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0 
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
