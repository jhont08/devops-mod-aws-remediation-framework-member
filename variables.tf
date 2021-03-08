# This sets up the member account
variable "master" {
  type        = string
  description = <<EOT
    Master account id. This is expected to be set to the account where remediator is deployed
  EOT
}
