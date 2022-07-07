provider "aws" {
  region  = var.region
}

module "security" {
  source = "./security"
}


module "Standardization" {
  source = "./Standardization"
  role_arn = var.role_arn

}

module "logs" {
  source = "./logs"
  s3_bucketname = var.s3_bucketname
}

