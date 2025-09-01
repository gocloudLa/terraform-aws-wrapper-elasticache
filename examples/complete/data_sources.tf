data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.common_name}"]
  }
}
data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Name = "${local.common_name}-db*"
  }
}
