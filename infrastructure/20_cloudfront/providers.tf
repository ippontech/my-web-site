provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = basename(abspath("${path.module}/../.."))
      subproject = basename(abspath(path.module))
    }
  }
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"

  default_tags {
    tags = {
      project    = basename(abspath("${path.module}/../.."))
      subproject = basename(abspath(path.module))
    }
  }
}
