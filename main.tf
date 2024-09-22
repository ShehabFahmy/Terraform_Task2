#region Task 2
module "vpc" {
  source     = "./Modules/vpc"
  name       = "tf-task2-vpc"
  cidr-block = "10.0.0.0/16"
  created-by = var.me
}

module "pb-subnet1" {
  source            = "./Modules/subnet"
  name-and-cidr     = ["tf-task2-pb-subnet1", "10.0.0.0/24"]
  availability-zone = "us-east-1a"
  created-by        = var.me
  vpc-id            = module.vpc.id
}

module "pb-subnet2" {
  source            = "./Modules/subnet"
  name-and-cidr     = ["tf-task2-pb-subnet2", "10.0.2.0/24"]
  availability-zone = "us-east-1b"
  created-by        = var.me
  vpc-id            = module.vpc.id
}

module "pv-subnet1" {
  source            = "./Modules/subnet"
  name-and-cidr     = ["tf-task2-pv-subnet1", "10.0.1.0/24"]
  availability-zone = "us-east-1a"
  created-by        = var.me
  vpc-id            = module.vpc.id
}

module "pv-subnet2" {
  source            = "./Modules/subnet"
  name-and-cidr     = ["tf-task2-pv-subnet2", "10.0.3.0/24"]
  availability-zone = "us-east-1b"
  created-by        = var.me
  vpc-id            = module.vpc.id
}

module "igw" {
  source     = "./Modules/internet_gateway"
  name       = "tf-task2-igw"
  created-by = var.me
  vpc-id     = module.vpc.id
}

module "pb-rtb" {
  source     = "./Modules/public_route_table"
  name       = "tf-task2-pb-rtb"
  created-by = var.me
  vpc-id     = module.vpc.id
  igw-id     = module.igw.id
}

module "pv-rtb" {
  source     = "./Modules/private_route_table"
  name       = "tf-task2-pv-rtb"
  created-by = var.me
  vpc-id     = module.vpc.id
}

module "public-associations" {
  source     = "./Modules/route_table_association"
  subnet-ids = [module.pb-subnet1.id, module.pb-subnet2.id]
  rtb-id     = module.pb-rtb.id
}

module "private-associations" {
  source     = "./Modules/route_table_association"
  subnet-ids = [module.pv-subnet1.id, module.pv-subnet2.id]
  rtb-id     = module.pv-rtb.id
}

module "key-pair" {
  source   = "./Modules/key_pair"
  key-name = "tf-task2-key-pair"
}
#endregion
