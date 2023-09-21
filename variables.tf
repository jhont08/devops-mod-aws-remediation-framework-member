# This sets up the member account
variable "master" {
  type        = string
  description = "Master account id. This is expected to be set to the account where remediator is deployed"
}

variable "region" {
  type        = string
  description = "Master account region"
}

variable "tags" {
  type        = map(string)
  description = "Map of default tags for resources"
}
