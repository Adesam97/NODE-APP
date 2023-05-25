output "lb_endpoint" {
  value = "http://${aws_lb.node-lb.dns_name}"
}


output "asg_name" {
  value = aws_autoscaling_group.node-asg.name
}