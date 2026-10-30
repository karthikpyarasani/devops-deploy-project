terraform {
  backend "s3" {
    bucket       = "tfstate-383344223661-eu-north-1"
    key          = "web/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
