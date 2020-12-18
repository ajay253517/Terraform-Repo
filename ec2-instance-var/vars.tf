variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "ap-south-1"
}



variable "AMIS" {
  type = map(string)
  default = {
    ap-south-1= "ami-0d9462a653c34dab7"
    us-east-2 = "ami-0a887e401f7654935"
    eu-west-1 = "ami-01c94064639c71719"
  }
}

