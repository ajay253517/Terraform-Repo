terraform {
  required_version = ">= 0.13"
  required_providers {
    random ={
      version= "~> 2.1"
    }
    local ={
      version = "~> 1.2"
    }
    null ={
      version = "~> 2.1"
    }
    template ={
      version = "~> 2.1"
    }
  }
}

provider aws {
      version = "~> 2.70"
      region = var.region
      profile = "eks"
    }


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "dev-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "172.31.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  ingress {
    from_port = 30000
    to_port =  32767
    protocol = "tcp"

    cidr_blocks = ["124.40.245.74/32"]
  }
}


module "eks" {
  source          = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v12.2.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  subnets         = var.subnets
  kubeconfig_name = "kubeconfig-eks"
  kubeconfig_aws_authenticator_env_variables = { AWS_PROFILE = "eks" }

  tags = {
    Environment = "dev"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-dev"
      instance_type                 = var.instance_type
      asg_min_size                  = 1
      asg_desired_capacity          = 1
      asg_max_size                  = 3
      asg_force_delete              = true
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  workers_additional_policies          = ["arn:aws:iam::150700732942:policy/ebs-csi-policy"]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}