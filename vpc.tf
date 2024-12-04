resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enabledns_hostnames
  tags                 = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc" })
}

resource "aws_subnet" "public_subents" {
  count                   = length(var.public_subents_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subents_cidrs, count.index)
  availability_zone       = element(var.aws_azs_list, count.index)
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-public_subnet-${count.index + 1}" }
  , { "kubernetes.io/role/elb" : "1" })
}

resource "aws_subnet" "private_subents" {
  count             = length(var.private_subents_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subents_cidrs, count.index)
  availability_zone = element(var.aws_azs_list, count.index)
  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-private_subnet-${count.index + 1}" }
  , { "kubernetes.io/role/internal-elb" : "1" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-igw" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-public-rt" })
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.public_subents_cidrs)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subents[count.index].id
}

resource "aws_eip" "eips" {
  count      = length(var.public_subents_cidrs)
  domain     = "vpc"
  tags       = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-eip-${count.index + 1}" })
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_gate_ways" {
  count         = length(var.public_subents_cidrs)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public_subents[count.index].id
  tags          = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-nat-gate-way-${count.index + 1}" })
}

resource "aws_route_table" "private_rts" {
  count  = length(var.private_subents_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gate_ways[count.index].id
  }
  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-vpc-private-rt-${count.index + 1}" })
}

resource "aws_route_table_association" "private_rts_association" {
  count          = length(var.private_subents_cidrs)
  route_table_id = aws_route_table.private_rts[count.index].id
  subnet_id      = aws_subnet.private_subents[count.index].id
}