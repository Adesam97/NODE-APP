resource "aws_vpc" "node-app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "node-app-vpc"
  }
}

resource "aws_subnet" "node_public_subnet1" {
  vpc_id                                      = aws_vpc.node-app_vpc.id
  cidr_block                                  = var.subnet_cidr_blocks[0]
  map_public_ip_on_launch                     = true
  availability_zone                           = data.aws_availability_zones.node.names[0]
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "node_public_subnet1"
  }
}

resource "aws_subnet" "node_public_subnet2" {
  vpc_id                                      = aws_vpc.node-app_vpc.id
  cidr_block                                  = var.subnet_cidr_blocks[1]
  map_public_ip_on_launch                     = true
  availability_zone                           = data.aws_availability_zones.node.names[1]
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "node_public_subnet2"
  }
}

resource "aws_internet_gateway" "node_igw" {
  vpc_id = aws_vpc.node-app_vpc.id

  tags = {
    Name = "node_igw"
  }
}

resource "aws_route_table" "node_rt" {
  vpc_id = aws_vpc.node-app_vpc.id

  tags = {
    Name = "node_rt"
  }
}

resource "aws_route" "node_route" {
  route_table_id         = aws_route_table.node_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.node_igw.id
  depends_on                = [aws_route_table.node_rt]
}

resource "aws_route_table_association" "node_rt_subnet1_association" {
  subnet_id      = aws_subnet.node_public_subnet1.id
  route_table_id = aws_route_table.node_rt.id
}

resource "aws_route_table_association" "node_rt_subnet2_association" {
  subnet_id      = aws_subnet.node_public_subnet2.id
  route_table_id = aws_route_table.node_rt.id
}

resource "aws_security_group" "node_inst-temp_sg" {
  name = "instance-temp-sg"
  description = "allow all from everywhere"
  # ingress {
  #   description = "http from lb"
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   #security_groups = [aws_security_group.node_lb_sg.id]
  # }

   ingress {
    description = "ssh from lb"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "https from lb"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.node_lb_sg.id]
  }

  egress {
    description = "all out"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.node_lb_sg.id]
  }

  vpc_id = aws_vpc.node-app_vpc.id
}

resource "aws_security_group_rule" "attach-node-lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks       = [aws_vpc.node-app_vpc.cidr_block]
  source_security_group_id = aws_security_group.node_lb_sg.id
  security_group_id = aws_security_group.node_inst-temp_sg.id
}

resource "aws_security_group" "node_lb_sg" {
  name = "node_lb_sg"
  description = "allow http from everywhere"
  ingress {
    description = "http from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.node-app_vpc.id
}

resource "aws_launch_template" "node-launch-template" {
  name          = "node-aws-asg"
  image_id        = "ami-0715c1897453cabd1"
  instance_type   = "t2.micro"

  vpc_security_group_ids = [ aws_security_group.node_inst-temp_sg.id ] 

  tags = {
    Name = "node-app"
  }

  monitoring {
    enabled = true
  }

  user_data       = base64encode(file("./userdata.sh"))
}

resource "aws_lb_target_group" "node-target" {
  name     = "node-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.node-app_vpc.id
}

resource "aws_autoscaling_group" "node-asg" {
  name                 = "node-asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  #desired_capacity    = lookup(var.no-of-instance, var.my-environment)
  vpc_zone_identifier  = [aws_subnet.node_public_subnet1.id , aws_subnet.node_public_subnet2.id]
  health_check_type    = "ELB"
  health_check_grace_period = 400

  launch_template {
    id      = aws_launch_template.node-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "node-app-asg"
    propagate_at_launch = true
  }

  target_group_arns = [ aws_lb_target_group.node-target.arn ]

}

# resource "aws_lb_target_group_attachment" "node-asg" {
#   target_group_arn = aws_lb_target_group.node-target.arn
#   target_id        = aws_autoscaling_group.node-asg.id
#   port             = 80
# }

resource "aws_lb" "node-lb" {
  name               = "node-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.node_lb_sg.id]
  subnets            = [aws_subnet.node_public_subnet1.id , aws_subnet.node_public_subnet2.id]
}

resource "aws_lb_listener" "node-lb-listen" {
  load_balancer_arn = aws_lb.node-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node-target.arn
  }
}

resource "aws_autoscaling_attachment" "node-asg-attach" {
  autoscaling_group_name = aws_autoscaling_group.node-asg.name
  lb_target_group_arn   = aws_lb_target_group.node-target.arn
}
