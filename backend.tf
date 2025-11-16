# Backend configuration for Terraform state storage
# State file will be stored in S3 with file-based locking
terraform {
  backend "s3" {
    bucket       = "klypup-sanbox-093667081182-terraform-statefiles"
    key          = "package3/production/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true

    # State file location:
    # s3://klypup-sanbox-093667081182-terraform-statefiles/package3/production/terraform.tfstate

    # Note: Ensure S3 bucket has versioning enabled for state file history
  }
}
