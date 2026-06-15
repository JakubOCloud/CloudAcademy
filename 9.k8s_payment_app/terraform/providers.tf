provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      project = "payment-app"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
