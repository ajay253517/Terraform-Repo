terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "eks"
}

resource "aws_iam_role" "s3_role" {
  name = "s3_role_ter"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_profile" {
  name = "s3_profile"
  role = aws_iam_role.s3_role.name
}


resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = aws_iam_role.s3_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_security_group" "ec2-role-sg" {
  name = "ec2-role-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["124.40.245.74/32", "192.168.0.109/32"]
  }
}

resource "aws_instance" "dev1" {
  ami                  = "ami-09a7bbd08886aafdf"
  instance_type        = "t2.micro"
  key_name             = "ap-south-terr"
  iam_instance_profile = aws_iam_instance_profile.s3_profile.name
  security_groups      = [aws_security_group.ec2-role-sg.name,"my-access-sg"]
}