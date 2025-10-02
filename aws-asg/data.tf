data "terraform_remote_state" "vpc_remote_data" {
  backend = "s3"
  config = {
    bucket  = "myterraform-bucket-state-201yw"
    key     = "${var.name}/vpc/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "app1_remote_data" {
  backend = "s3"
  config = {
    bucket  = "myterraform-bucket-state-201yw"
    key     = "${var.name}/Application-1/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "rds_remote_data" {
  backend = "s3"
  config = {
    bucket  = "myterraform-bucket-state-201yw"
    key     = "${var.name}/rds/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}
