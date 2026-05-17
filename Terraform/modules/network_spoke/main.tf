locals {
  
  arcanum_alb_logs_bucket_name = var.alb_access_logs_bucket != null ? var.alb_access_logs_bucket : (var.enable_alb_access_logs ? aws_s3_bucket.arcanum_alb_logs_bucket01[0].bucket : null)
}

resource "aws_vpc" "arcanum_vpc01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc01"
  })
}

resource "aws_internet_gateway" "arcanum_igw01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw01"
  })
}

resource "aws_subnet" "arcanum_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.arcanum_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-subnet0${count.index + 1}"
  })
}

resource "aws_subnet" "arcanum_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.arcanum_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet0${count.index + 1}"
  })
}

resource "aws_eip" "arcanum_nat_eip01" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-eip01"
  })
}

resource "aws_nat_gateway" "arcanum_nat01" {
  allocation_id = aws_eip.arcanum_nat_eip01.id
  subnet_id     = aws_subnet.arcanum_public_subnets[0].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat01"
  })

  depends_on = [aws_internet_gateway.arcanum_igw01]
}

resource "aws_route_table" "arcanum_public_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt01"
  })
}

resource "aws_route" "arcanum_public_default_route" {
  route_table_id         = aws_route_table.arcanum_public_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.arcanum_igw01.id
}

resource "aws_route_table_association" "arcanum_public_rta" {
  count          = length(aws_subnet.arcanum_public_subnets)
  subnet_id      = aws_subnet.arcanum_public_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_public_rt01.id
}

resource "aws_route_table" "arcanum_private_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt01"
  })
}

resource "aws_route" "arcanum_private_default_route" {
  route_table_id         = aws_route_table.arcanum_private_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.arcanum_nat01.id
}

resource "aws_route_table_association" "arcanum_private_rta" {
  count          = length(aws_subnet.arcanum_private_subnets)
  subnet_id      = aws_subnet.arcanum_private_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_private_rt01.id
}

############################################
# Application Load Balancer
############################################

resource "aws_security_group" "arcanum_alb_sg01" {
  name        = "${var.project_name}-alb-sg01"
  description = "ALB security group"
  vpc_id      = aws_vpc.arcanum_vpc01.id

  # Public Ingress
  dynamic "ingress" {
    for_each = var.alb_allow_public_http_https ? [1] : []
    content {
      description = "HTTP from internet (redirect to HTTPS)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.alb_allow_public_http_https ? [1] : []
    content {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress: ALB -> targets (usually port 80). You can tighten later if you want.
  egress {
    description = "ALB to targets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg01" }
}

resource "aws_lb" "arcanum_alb01" {
  name               = "${var.project_name}-alb01"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.arcanum_alb_sg01.id]
  subnets         = aws_subnet.arcanum_public_subnets[*].id

  # Explanation: arcanum keeps flight logs—ALB access logs go to S3 for audits and incident response.
  dynamic "access_logs" {
    for_each = var.enable_alb_access_logs ? [1] : []
    content {
      bucket  = local.arcanum_alb_logs_bucket_name
      prefix  = var.alb_access_logs_prefix
      enabled = var.enable_alb_access_logs
    }
  }

  depends_on = [
    aws_s3_bucket_policy.arcanum_alb_logs_policy01,
    aws_s3_bucket_public_access_block.arcanum_alb_logs_pab01
  ]

  tags = { Name = "${var.project_name}-alb01" }
}

############################################
# Target Group + Attachment
############################################

resource "aws_lb_target_group" "arcanum_tg01" {
  name     = "${var.project_name}-tg01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.arcanum_vpc01.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "${var.project_name}-tg01" }
}


############################################
# ALB Listeners: HTTP -> HTTPS redirect, HTTPS -> (Lab1 forward OR Lab2 deny+rule)
############################################

resource "aws_lb_listener" "arcanum_http_listener01" {
  load_balancer_arn = aws_lb.arcanum_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcanum_tg01.arn
  }
}
