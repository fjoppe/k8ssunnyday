# Create vpc for the cluster
resource "aws_vpc" "k8vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.tag_name}"
  }
}


#  Retrieve the availability zones for the AWS region
data "aws_availability_zones" "available" {
  state = "available"
}


# Create public subnets
resource "aws_subnet" "pubsubnets" {
  # loop over the availability zones, we create a subnet per AZ
  count =  length(data.aws_availability_zones.available.names)

  # Explanation of "cidrsubnet" function parameters, please refer to terraform documentation for more info.
  #
  # Setup cidr blocks for the subnets with base 10.0.16.0/20
  #
  #       10         0        16         0 / 20
  # 00001010  00000000  00010000  00000000
  # -----------------------><------------- (first 20 bits = network, then 12 bits = host)
  # network ---------------><-------- host (10.0.16.0/20)
  # 
  # For this pattern: "10.0.16.0/20", "10.0.32.0/20",  "10.0.48.0/20", "10.0.64.0/20"
  # we must iterate over the 4 rightmost bits in the network part.
  # For this we set newbits=4 in the call to the cidrsubnet function.
  # This also decreases the subnetmask from 20 to 16 bits:
  #
  #       10         0        16         0 / 20
  # 00001010  00000000  00010000  00000000
  # ------------------->----<------------- (first 16 bits = network, then 4 bits = newbits, 12 bits = host)
  # network ----------->nwbt<-------- host (10.0.16.0/20)
  #
  # network = 16 bits, nwbt/newbits = 4 bits, host remains 12 bits
  # Note that this is compatible with the cidr of our VPC defined above.

  cidr_block =  cidrsubnet("10.0.16.0/16", 4, count.index)
  vpc_id = aws_vpc.k8vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = tomap({
    Name = "${data.aws_availability_zones.available.names[count.index]}-k8ssubnet"

    # These tags are used by the ALB ingress controller for autodetect subnets.
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.clustername}" = "owned"
  })
}


# Internet gateway for public subnet 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.k8vpc.id}"

  tags = {
    Name = "${var.tag_name}"
  }
}


# Create routing from internet
resource "aws_route_table" "igroute" {
  vpc_id = aws_vpc.k8vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}


# Add internet ingress routing to public subnet
resource "aws_route_table_association" "igwrouteassoc" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = aws_subnet.pubsubnets[count.index].id
  route_table_id = aws_route_table.igroute.id  
}

