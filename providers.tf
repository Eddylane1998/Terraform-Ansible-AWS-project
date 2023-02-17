terraform {
  backend "s3" {
    bucket = "github-oidc-terraform-ansible-aws-tfstates"
    key    = "devops"
  }
}
