variable "region" {
  default = "us-east-1"
}

provider "aws" {
    profile = "default"
    region = "${var.region}"
}

terraform {
  backend "s3" {}
}

// this will fetch our account_id, no need to hard code it
data "aws_caller_identity" "current" {}
