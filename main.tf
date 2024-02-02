module "us_east_instances" {
  source = "./modules/ec2"

  instance_count = 5
  aws_region = "us-east-1"
}

module "ap_northeast_instances" {
  source = "./modules/ec2"

  instance_count = 1
  aws_region = "ap-northeast-1"
}

module "eu_west_instances" {
  source = "./modules/ec2"

  instance_count = 1
  aws_region = "eu-west-2"
}