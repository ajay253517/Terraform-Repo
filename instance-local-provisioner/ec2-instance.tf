terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.70"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "eks"
}



resource "aws_security_group" "web_server_sg" {
  name = "web_server_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["124.40.245.74/32", "192.168.0.108/32"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]   
  }
}


resource "aws_security_group" "access_ssh" {
  name = "access_ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["124.40.245.74/32", "192.168.0.108/32"]
  }
}




resource "aws_instance" "web_server" {
  ami             = "ami-09a7bbd08886aafdf"
  instance_type   = "t2.micro"
  key_name        = "ap-south-terr"
  security_groups = [aws_security_group.web_server_sg.name, aws_security_group.access_ssh.name]
  user_data = <<EOF
    #!/bin/bash
      sudo mkdir -p /var/www/html
      sudo chwon -R ec2-user:ec2-user  /var/www/html
      sudo yum update -y 
      sudo yum install -y python 
  EOF  
  provisioner "remote-exec" {
    inline = ["sudo hostname"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/root/exec-instance/ap-south-terr.pem")
      host        = aws_instance.web_server.public_ip
    }
  }
  provisioner "file" {
    source      = "log-file.txt"
    destination = "/tmp/log-file.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/root/exec-instance/ap-south-terr.pem")
      host        = aws_instance.web_server.public_ip
    }
  }


  provisioner "local-exec"{
    command = "echo ${aws_instance.web_server.public_ip} > ec2-hosts.ini"
  }
  
  provisioner "file" {
    source      = "my-site"
    destination = "/tmp"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/root/exec-instance/ap-south-terr.pem")
      host        = aws_instance.web_server.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key /root/exec-instance/ap-south-terr.pem -i ec2-hosts.ini web-server.yaml"
  }
}


sudo amazon-linux-extras install epel
 


 
