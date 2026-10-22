terraform {
  backend "s3" {
    bucket = "route-dev-env-ghada"
    key    = "route/us-east-1/dev/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true //to lock state file when a user hits terraform apply while another terraform apply was running
  }
}