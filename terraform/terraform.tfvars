vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
aws_region           = "us-east-1"
ami_id               = "ami-020cba7c55df1f615" # Ubuntu 22.04 in us-east-1
instance_type        = "t2.micro"