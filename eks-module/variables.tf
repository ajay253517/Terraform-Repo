variable "region" {
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}


variable "vpc_id" {
  default = "vpc-xxxxxxxx"
}

variable "subnets" {
  type     = list(string)
  default = ["subnet-aaaaaaaa", "subnet-bbbbbbbb", "subnet-cccccccc"]
}

variable "instance_type" {
  type = string
}