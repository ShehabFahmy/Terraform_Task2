resource "aws_route_table" "pv-rtb" {
  vpc_id = var.vpc-id

  tags = {
    Name = var.name
    Created_by = var.created-by
  }
}
