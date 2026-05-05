variable "github_repo" {
  description = "myrepo for roles"
}

variable "tf_state_bucket" {
  description = "remote state bucket"
}

variable "lock_table_name" {
  description = "dynamoDB lock"
}

variable "tags" {
  default = {
    project = "static-website"
  }
}
