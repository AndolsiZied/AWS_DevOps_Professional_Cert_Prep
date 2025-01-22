resource "aws_launch_template" "cert-prep" {
  name          = "cert-prep-launch-template"
  image_id      = var.ami_id
  instance_type = var.ec2_instance_type


  user_data = base64encode(
    <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "Hello from $(hostname)" > /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.cert-prep.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cert-prep-instance"
    }
  }
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
}

resource "aws_security_group" "asg_sg" {
  name        = "cert-prep-asg-sg"
  description = "Security Group for ASG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cert-prep-asg-sg"
  }
}

resource "aws_iam_role" "cert-prep" {
  name = "cert-prep-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "cert-prep" {
  name = "cert-prep-instance-profile"
  role = aws_iam_role.cert-prep.name
}

resource "aws_autoscaling_group" "cert-prep" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity  = 0
      spot_allocation_strategy = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.cert-prep.id
        version            = "$Latest"
      }
    }
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"
}

resource "aws_iam_policy" "ec2_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:DescribeInstances", "cloudwatch:PutMetricData"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.cert-prep.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}
