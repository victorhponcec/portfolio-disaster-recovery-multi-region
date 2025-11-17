provider "aws" {
  region = var.region1
  default_tags {
    tags = {
      Project = "Security"
      Name    = "Victor-Ponce"
    }
  }
}

# ACM for ALB | Region 2
provider "aws" {
  alias  = "west1"
  region = "us-west-1"
}

# ACM for CloudFront
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}