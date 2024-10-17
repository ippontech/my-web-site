provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = basename(abspath("${path.module}/../.."))
      subproject = basename(abspath(path.module))
    }
  }
}
