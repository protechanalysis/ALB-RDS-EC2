terraform {
  backend "s3" {
    bucket       = "ha-terraform-infra-web-database"
    key          = "terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}
