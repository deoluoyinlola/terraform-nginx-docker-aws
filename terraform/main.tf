terraform {
   backend "s3" {
     bucket         = "first-tf-state"
     key            = "global/s3/terraform.tfstate"
     region         = "us-east-1"
     access_key     = "AKIA52WMJFUL7YM5CFIY"
     secret_key     = "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"
     dynamodb_table = "terraform-state-locking"
     encrypt        = true
   }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA52WMJFUL7YM5CFIY"
  secret_key = "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"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "first-tf-state"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

variable vpc_cidr_block {}
variable subnet_1_cidr_block {}
variable avail_zone {}
variable env_prefix {}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
      Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_1_cidr_block
  availability_zone = var.avail_zone
  tags = {
      Name = "${var.env_prefix}-subnet-1"
  }
}