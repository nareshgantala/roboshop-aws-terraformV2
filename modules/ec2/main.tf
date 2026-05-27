resource "aws_instance" "example" {
  ami           = "ami-0fdfb4d987b63ae72"
  instance_type = var.instance_type

  tags = {
    Name = "roboshop-${var.component}"
  }
}