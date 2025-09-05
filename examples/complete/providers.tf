provider "aws" {
  region = local.metadata.aws_region
}

provider "aws" {
  region = "us-east-2"
  alias  = "use2"
}
