resource "aws_instance" "terra-ec2-test" {
  ami           = local.instance_ami
  instance_type = var.instance_type
  subnet_id     = local.subnet_id
}

resource "aws_instance" "import" {
  ami           = local.instance_ami
  instance_type = var.instance_type
  subnet_id     = local.subnet_id
}
