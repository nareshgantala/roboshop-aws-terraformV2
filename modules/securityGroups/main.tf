resource "aws_security_group" "public_alb" {
  vpc_id = var.vpc_id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-public-alb-sg"
  }

}


resource "aws_security_group" "frontend_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.public_alb.id]
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
  }

  egress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-frontend-sg"
  }
  
}

resource "aws_security_group" "internal_alb" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.frontend_sg.id]
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-internal-alb-sg"
  }

}


resource "aws_security_group" "cart_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8003
    to_port          = 8003
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-cart-sg"
  }

}


resource "aws_security_group" "catalogue_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8002
    to_port          = 8002
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-catalogue-sg"
  }

}

resource "aws_security_group" "user_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8001
    to_port          = 8001
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-user-sg"
  }

}

resource "aws_security_group" "shipping_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8004
    to_port          = 8004
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-shipping-sg"
  }

}

resource "aws_security_group" "payment_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8005
    to_port          = 8005
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-payment-sg"
  }

}

resource "aws_security_group" "ratings_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8006
    to_port          = 8006
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-ratings-sg"
  }

}


resource "aws_security_group" "orders_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8007
    to_port          = 8007
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-orders-sg"
  }

}


resource "aws_security_group" "mysql_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8007
    to_port          = 8007
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-mysql-sg"
  }

}


resource "aws_security_group" "rabbitmq_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8007
    to_port          = 8007
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-rabbitmq-sg"
  }

}

resource "aws_security_group" "mongo_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8007
    to_port          = 8007
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-mongo-sg"
  }

}

resource "aws_security_group" "valkey_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id]
    from_port        = 8007
    to_port          = 8007
    protocol         = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "roboshop-valkey-sg"
  }

}

