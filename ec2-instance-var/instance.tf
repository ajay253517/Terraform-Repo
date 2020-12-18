resource "aws_instance" "ec2_var" {
  ami = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  key_name     = "terraform-key.pem"
}