resource "aws_lb" "this" {

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "openwebui" {

  name        = "${var.project_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {

    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3

  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Project     = var.project_name
    Environment = var.environment
  }

}

resource "aws_lb_target_group_attachment" "openwebui" {

  target_group_arn = aws_lb_target_group.openwebui.arn

  target_id = var.target_instance_id

  port = 80

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "redirect"

    redirect {

      port = "443"

      protocol = "HTTPS"

      status_code = "HTTP_301"

    }

  }

}
resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.this.arn

  port = 443

  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = var.certificate_arn

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.openwebui.arn

  }

}  
