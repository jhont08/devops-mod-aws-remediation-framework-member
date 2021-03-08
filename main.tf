provider "aws" {
  region  = "us-east-2"
}

# Setup the event forwarders in each region
# Terraform doesn't support count or for_each in modules, revisit after terraform 0.13 release
module "event-fowarder-us-east-1" {
  source = "./event_forwarder"
  region = "us-east-1"
  master = var.master
  role_arn = aws_iam_role.event_forward.arn
}

module "event-forwarder-us-east-2" {
  source = "./event_forwarder"
  region = "us-east-2"
  master = var.master
  role_arn = aws_iam_role.event_forward.arn
}

