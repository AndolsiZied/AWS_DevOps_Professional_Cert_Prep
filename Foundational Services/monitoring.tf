resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cert-prep.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cert-prep.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high-alarm"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 70
  period              = 300
  evaluation_periods  = 2
  alarm_description   = "Triggered when CPU utilization exceeds 70% for 10 minutes"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cert-prep.name
  }

  alarm_actions = [
    aws_sns_topic.example.arn,
    aws_autoscaling_policy.scale_up.arn
  ]

  ok_actions = [
    aws_autoscaling_policy.scale_down.arn
  ]
}

resource "aws_sns_topic" "example" {
  name = "cert-prep-sns-topic"
}

resource "aws_sns_topic_subscription" "example" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
