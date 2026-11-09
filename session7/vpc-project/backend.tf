terraform {
  backend "s3" {
    bucket       = "vpc-lab-ghada"
    key          = "route/us-east-1/session7/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true //to lock state file when a user hits terraform apply while another terraform apply was running
  }
}
