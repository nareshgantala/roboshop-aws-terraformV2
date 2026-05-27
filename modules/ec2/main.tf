resource "aws_instance" "db_instance" {
  ami           = "ami-0fdfb4d987b63ae72"
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.sg]
  key_name               = "roboshop_pem"
  tags = {
    Name = "roboshop-${var.component}"
  }
}