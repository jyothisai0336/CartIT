resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-vpc" })
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project}-${var.env}-igw" })
}
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-public-${count.index+1}", "kubernetes.io/role/elb" = "1" })
}
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index+length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-private-${count.index+1}", "kubernetes.io/role/internal-elb" = "1" })
}
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.project}-${var.env}-eip-${count.index+1}" })
}
resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.project}-${var.env}-nat-${count.index+1}" })
  depends_on    = [aws_internet_gateway.igw]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.igw.id }
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-rt-public" })
}
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; nat_gateway_id = aws_nat_gateway.nat[count.index].id }
  tags = merge(var.tags, { Name = "${var.project}-${var.env}-rt-private-${count.index+1}" })
}
resource "aws_route_table_association" "public"  { count = length(var.availability_zones); subnet_id = aws_subnet.public[count.index].id;  route_table_id = aws_route_table.public.id }
resource "aws_route_table_association" "private" { count = length(var.availability_zones); subnet_id = aws_subnet.private[count.index].id; route_table_id = aws_route_table.private[count.index].id }
resource "aws_flow_log" "main" {
  vpc_id = aws_vpc.main.id; traffic_type = "ALL"
  iam_role_arn = aws_iam_role.flow_log.arn; log_destination = aws_cloudwatch_log_group.flow_log.arn
}
resource "aws_cloudwatch_log_group" "flow_log" { name = "/aws/vpc/${var.project}-${var.env}/flow-logs"; retention_in_days = 30 }
resource "aws_iam_role" "flow_log" {
  name = "${var.project}-${var.env}-flow-log-role"
  assume_role_policy = jsonencode({ Version="2012-10-17"; Statement=[{ Action="sts:AssumeRole"; Effect="Allow"; Principal={ Service="vpc-flow-logs.amazonaws.com" } }] })
}
resource "aws_iam_role_policy" "flow_log" {
  role = aws_iam_role.flow_log.id
  policy = jsonencode({ Version="2012-10-17"; Statement=[{ Effect="Allow"; Action=["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogGroups","logs:DescribeLogStreams"]; Resource="*" }] })
}
