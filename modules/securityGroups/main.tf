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

# 1. Clear out the inline ingress from the parent resource definition
resource "aws_security_group" "frontend_sg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "roboshop-frontend-sg"
  }
}

# 2. Add the Public ALB inbound traffic as its own standalone rule resource
resource "aws_security_group_rule" "frontend_ingress_from_public_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.public_alb.id
}

# 3. Your Debugging SSH rule (Kept exactly as you wrote it)
resource "aws_security_group_rule" "frontend_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_sg.id
}

# 4. Your Outbound Internet rule (Kept exactly as you wrote it)
resource "aws_security_group_rule" "frontend_to_internet_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" 
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.frontend_sg.id
}

# 5. Your Internal ALB Bridge rule (Kept exactly as you wrote it)
resource "aws_security_group_rule" "frontend_egress_to_internal_alb" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.internal_alb.id
}



resource "aws_security_group" "internal_alb" {
  vpc_id = var.vpc_id

  # REMOVED: Ingress rule pointing directly to frontend_sg moved below to break the loop

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

# --- BRIDGE RULE: Internal ALB in from Frontend ---
resource "aws_security_group_rule" "internal_alb_ingress_from_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb.id
  source_security_group_id = aws_security_group.frontend_sg.id
}


# ====================================================================
# MICROSERVICES & DATABASE GROUPS (Untouched & Completely Valid)
# ====================================================================

resource "aws_security_group" "cart_sg" {
  vpc_id = var.vpc_id
  ingress {
    security_groups = [aws_security_group.internal_alb.id, aws_security_group.payment_sg.id]
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
    security_groups = [aws_security_group.internal_alb.id, aws_security_group.cart_sg.id]
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
    security_groups = [aws_security_group.internal_alb.id, aws_security_group.payment_sg.id]
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
    security_groups = [aws_security_group.internal_alb.id, aws_security_group.orders_sg.id]
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
    security_groups = [aws_security_group.catalogue_sg.id, aws_security_group.ratings_sg.id, aws_security_group.shipping_sg.id]
    from_port        = 3306
    to_port          = 3306
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
    security_groups = [aws_security_group.orders_sg.id, aws_security_group.payment_sg.id]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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
    security_groups = [aws_security_group.orders_sg.id, aws_security_group.user_sg.id]
    from_port        = 27017
    to_port          = 27017
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
    security_groups = [aws_security_group.cart_sg.id]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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


resource "aws_security_group" "database_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "roboshop-database-sg"
  }
}