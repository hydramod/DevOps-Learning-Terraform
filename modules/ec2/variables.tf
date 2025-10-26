variable "instance_type" {
  type = string
  default = "t3.micro"
}

locals {
  instance_ami = "ami-0360c520857e3138f"
  subnet_id = "subnet-05925340419cda411"
}

output "instance_id" {
  description = "Instance ID"
  value = aws_instance.terra-ec2-test
}