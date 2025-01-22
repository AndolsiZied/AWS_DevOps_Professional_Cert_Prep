resource "aws_security_group" "lb_sg" {
  name        = "cert-prep-lb-sg"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ip_white_list
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cert-prep-lb-sg"
  }
}

resource "aws_lb" "cert-prep-alb" {
  name                       = "cert-prep-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "cert-prep-alb-group" {
  name     = "cert-prep-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cert-prep-alb.arn
  port              = "80"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = 200
      message_body = "OK"
    }
  }
}
