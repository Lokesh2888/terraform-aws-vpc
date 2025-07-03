data "aws_availability_zones" "available" {
  state = "available"
}

# output "azs_info" {
#   value = data.aws_availability_zone.available
# }