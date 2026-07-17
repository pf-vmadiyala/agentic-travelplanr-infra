

# Fetch available availability zones in the active AWS region dynamically
data "aws_availability_zones" "available" {
  state = "available"
}
