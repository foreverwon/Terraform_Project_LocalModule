# aws_launch_configuration ( UserData 수정, name 삭제 [중복문제 발생]  )
resource "aws_launch_template" "aws_asg_launch" {
  image_id        = "ami-0ea4d4b8dc1e46212"
  instance_type   = var.instance_type
  key_name        = data.aws_key_pair.EC2-Key.key_name
  network_interfaces {
    security_groups = [var.SSH_SG_ID, var.HTTP_HTTPS_SG_ID]
  }
  # UserData 변경
  user_data       = base64encode(<<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "<h1>Hello My WEB</h1>" > /var/www/html/index.html
  EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "aws_asg" {
  # Launch Configuration 변경 시 새로운 ASG가 배포되도록 의존관계를 Name으로 정의한다.
  name                 = "${var.name}-${aws_launch_template.aws_asg_launch.name}"
  launch_template {
    name    = aws_launch_template.aws_asg_launch.name
    version = "$Latest"
  }
  desired_capacity     = var.desired_size
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = var.private_subnets

  target_group_arns = [data.terraform_remote_state.alb_remote_data.outputs.ALB_TG]
  health_check_type = "ELB"

  # 교체용 ASG 생성 후 기존 ASG 삭제를 위한 LifeCycle 설정
  lifecycle {
    create_before_destroy = true
  }

  # 교체용 ASG 배포 완료를 고려하기 전 최소 인스턴스 수 만큼 상태검사를 통과할 때까지 대기 후 배포완료
  min_elb_capacity  = var.min_size

  tag {
    key                 = "Name"
    value               = "${var.name}-Terraform_Instance"
    propagate_at_launch = true
  }
}

