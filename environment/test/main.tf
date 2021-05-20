data "aws_region" "current" {}

terraform {
  required_version = "~> 0.14"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "xxx"
    key     = "keys-rotation.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "default"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


locals {
  tags = {
    Environment  = var.environment
    Region       = data.aws_region.current.name
    Purpose      = "Automated Key Rotation"
    Terraform    = true
  }
}

module "automated_key_rotation" {
  source                            = "../../modules/layers/automated_key_rotation"
  cloudwatch_event_name             = "${var.application}-key-rotation-cw-event"
  target_id                         = var.target_id
  lambda_policy_name                = "${var.application}-key-rotation-lambda-policy"
  lambda_role_name                  = "${var.application}-key-rotation-lambda-role"
  lambda_funcion_name               = "${var.application}-key-rotation-lambda-function"
  handler                           = var.handler
  runtime                           = var.runtime
  emails_count                      = length(var.emails_list)
  emails_list                       = var.emails_list
  schedule_expression               = var.schedule_expression
  principal                         = var.principal

  tags                              = local.tags
}