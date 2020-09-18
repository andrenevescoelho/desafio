resource "aws_instance" "megatron" {
  ami                    = "ami-0817d428a6fb68645"
  instance_type          = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids = [aws_security_group.instance.id]
  tags = {
    Name = "terraform-megatron"
  }
}

resource "aws_launch_configuration" "megatron" {
  image_id        = "ami-0817d428a6fb68645"
  instance_type   = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  security_groups = [aws_security_group.instance.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-megatron-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
}


resource "aws_security_group" "elb" {
  name = "terraform-megatron-elb"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "megatron" {
  name               = "terraform-asg-megatron"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = ["us-east-1c", "us-east-1d", "us-east-1b", "us-east-1f", "us-east-1a", "us-east-1e"]
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}


resource "aws_autoscaling_group" "megatron" {
  launch_configuration = aws_launch_configuration.megatron.id
  availability_zones = ["us-east-1c", "us-east-1d", "us-east-1b", "us-east-1f", "us-east-1a", "us-east-1e"]
  min_size = 2
  max_size = 10
  load_balancers    = [aws_elb.megatron.name]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "terraform-asg-megatron"
    propagate_at_launch = true
  }
}


output "clb_dns_name" {
  value       = aws_elb.megatron.dns_name
}

