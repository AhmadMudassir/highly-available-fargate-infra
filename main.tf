provider "aws" {
  region = var.region
}

resource "aws_vpc" "ahmad-vpc-terra" {
  cidr_block = var.vpc-cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "ahmad-vpc-terra"
    "owner" = "ahmad"
  }
}

######## Subnets #############
resource "aws_subnet" "ahmad-public-subnet1-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  availability_zone = "us-east-2a"
  cidr_block = var.subnet1-cidr
  tags = {
    "Name" = "ahmad-public-subnet1-terra"
    "owner" = var.owner
  }
}

resource "aws_subnet" "ahmad-private-subnet2-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet2-cidr
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "ahmad-private-subnet2-terra"
    "owner" = var.owner
  }
}

resource "aws_subnet" "ahmad-public-subnet3-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet3-cidr
  availability_zone = "us-east-2c"
  tags = {
    "Name" = "ahmad-public-subnet3-terra"
    "owner" = var.owner
  }
}

resource "aws_subnet" "ahmad-private-subnet4-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet4-cidr
  availability_zone = "us-east-2c"
  tags = {
    "Name" = "ahmad-private-subnet4-terra"
    "owner" = var.owner
  }
}

####### Elastic IPs ########
resource "aws_eip" "ahmad-nat1-eip-terra" {

  tags = {
    "Name" = "ahmad-nat1-eip-terra"
    "owner" = var.owner
  }
}

resource "aws_eip" "ahmad-nat2-eip-terra" {

  tags = {
    "Name" = "ahmad-nat2-eip-terra"
    "owner" = var.owner
  }
}

####### Gateways ##########
resource "aws_internet_gateway" "ahmad-igw-terra" {  
    vpc_id = aws_vpc.ahmad-vpc-terra.id
    tags = {
        "Name" = "ahmad-igw-terra"
        "owner" = var.owner
    }
}

resource "aws_nat_gateway" "ahmad-nat1-terra" {
  subnet_id = aws_subnet.ahmad-public-subnet1-terra.id
  allocation_id = aws_eip.ahmad-nat1-eip-terra.id

  tags = {
        "Name" = "ahmad-nat1-terra"
        "owner" = var.owner
  }
}

resource "aws_nat_gateway" "ahmad-nat2-terra" {
  subnet_id = aws_subnet.ahmad-public-subnet3-terra.id
  allocation_id = aws_eip.ahmad-nat2-eip-terra.id

  tags = {
        "Name" = "ahmad-nat2-terra"
        "owner" = var.owner
  }
}

###### Route Tables #########
resource "aws_route_table" "ahmad-public-sub-rt-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  route {
    cidr_block = var.all-traffic-cidr
    gateway_id = aws_internet_gateway.ahmad-igw-terra.id
  }
  tags = {
    "Name" = "ahmad-public-sub-rt-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table" "ahmad-private-sub1-rt-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  route {
    cidr_block = var.all-traffic-cidr
    nat_gateway_id = aws_nat_gateway.ahmad-nat1-terra.id
  }
  tags = {
    "Name" = "ahmad-private-sub1-rt-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table" "ahmad-private-sub2-rt-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  route {
    cidr_block = var.all-traffic-cidr
    nat_gateway_id = aws_nat_gateway.ahmad-nat2-terra.id
  }
  tags = {
    "Name" = "ahmad-private-sub2-rt-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table_association" "ahmad-subnet1-association" {
  subnet_id = aws_subnet.ahmad-public-subnet1-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_route_table_association" "ahmad-subnet2-association" {
  subnet_id = aws_subnet.ahmad-private-subnet2-terra.id
  route_table_id = aws_route_table.ahmad-private-sub1-rt-terra.id
}

resource "aws_route_table_association" "ahmad-subnet3-association" {
  subnet_id = aws_subnet.ahmad-public-subnet3-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_route_table_association" "ahmad-subnet4-association" {
  subnet_id = aws_subnet.ahmad-private-subnet4-terra.id
  route_table_id = aws_route_table.ahmad-private-sub2-rt-terra.id
}


########## SG ##############
resource "aws_security_group" "ahmad-sg-terra" {
  name = "Http and SSH"
  vpc_id = aws_vpc.ahmad-vpc-terra.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }

  ingress {
    from_port = 2049
    to_port= 2049
    protocol= "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.all-traffic-cidr]
  }  

  tags = {
    "Name" = "ahmad-sg-terra"
    "owner" = var.owner
  }
}

##################    ECS Resources    ##########################
resource "aws_ecs_cluster" "ahmad-ecs-cluster-terra" {
  name = "ahmad-ecs-cluster-terra"
  tags = {
    "Name" = "ahmad-ecs-cluster-terra"
    "owner" = var.owner
  }
}

resource "aws_ecs_task_definition" "ahmad-taskdef-terra" {
  family = "ahmad-taskdef-terra"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 1024
  memory = 2048
  
  execution_role_arn = "arn:aws:iam::504649076991:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
        name = "nginx-terra"
        image = "<aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:v1"
        cpu = 1024
        memory = 2048
        essential = true
        portMappings = [
            {
                containerPort = 80
                protocol = "tcp"
            }
        ],
        mountPoints: [
          {
              containerPath= "/mnt/efs",
              sourceVolume= "ahmad-efs"       
          }
        ]
    }
  ])

  volume {
    name = "ahmad-efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ahmad-efs.id
    }
  }

  depends_on = [ aws_ecr_repository.ahmad-repo-terra, null_resource.ecr-docker-push-ahmad, aws_efs_file_system.ahmad-efs ]
  tags = {
    "Name" = "ahmad-taskdef-terra"
    "owner" = var.owner
  }
}

resource "aws_ecs_service" "ahmad-service-terra" {
  name = "ahmad-service-terra"
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ahmad-ecs-cluster-terra.id
  task_definition = aws_ecs_task_definition.ahmad-taskdef-terra.arn
  desired_count = 2
  platform_version = "1.4.0"
  
  network_configuration {
    subnets = [aws_subnet.ahmad-private-subnet2-terra.id, aws_subnet.ahmad-private-subnet4-terra.id]
    security_groups = [aws_security_group.ahmad-sg-terra.id]
    assign_public_ip = false
  }
  
  load_balancer {
    container_name = "nginx-terra"
    container_port = 80
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
  }

  depends_on = [ aws_lb.ahmad-lb-terra ]
  tags = {
    "Name" = "ahmad-service-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecr_repository" "ahmad-repo-terra" {
  name = "ahmad-repo-terra"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  tags = {
    "Name" = "ahmad-repo-terra"
    "owner" = "ahmad"
  }
}

resource "null_resource" "ecr-docker-push-ahmad" {
  depends_on = [ aws_ecr_repository.ahmad-repo-terra ]
  provisioner "local-exec" {
    command = <<EOF
    docker build -t ahmad-nginx-html ./nginx-dockerfile
    aws ecr get-login-password --region <repo-name> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
    docker tag ahmad-nginx-html:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com<repo-name>:v1
    docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:v1
    EOF
  }
}

############ ALB Logic  ###############
resource "aws_lb" "ahmad-lb-terra" {
  name = "ahmad-lb-terra"
  load_balancer_type = "application"
  security_groups = [ aws_security_group.ahmad-sg-terra.id ]
  subnets = [ aws_subnet.ahmad-public-subnet1-terra.id, aws_subnet.ahmad-public-subnet3-terra.id ]

  tags = {
    "Name" = "ahmad-lb-terra"
    "owner" = "ahmad"
  }
}

resource "aws_lb_target_group" "ahmad-lb-targroup-terra" {
  name = "ahmad-lb-targroup-terra"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.ahmad-vpc-terra.id

   health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    "Name" = "ahmad-lb-target-terra"
    "owner" = "ahmad"
  }
}

resource "aws_lb_listener" "ahmad-lb-listener-terra" {
  load_balancer_arn = aws_lb.ahmad-lb-terra.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
  }

  tags = {
    "Name" = "ahmad-lb-listener-terra"
    "owner" = "ahmad"
  }
}



########### EFS Volume ############
resource "aws_efs_file_system" "ahmad-efs" {
  creation_token = "ahmad-efs"
  throughput_mode = "provisioned"
  provisioned_throughput_in_mibps = 1

  tags = {
    "Name" = "ahmad-efs"
    "owner" = "ahmad"
  }
}

resource "aws_efs_mount_target" "ahmad-efs-mt-1" {
  file_system_id  = aws_efs_file_system.ahmad-efs.id
  subnet_id       = aws_subnet.ahmad-private-subnet2-terra.id
  security_groups = [aws_security_group.ahmad-sg-terra.id]
}

resource "aws_efs_mount_target" "ahmad-efs-mt-2" {
  file_system_id  = aws_efs_file_system.ahmad-efs.id
  subnet_id       = aws_subnet.ahmad-private-subnet4-terra.id
  security_groups = [aws_security_group.ahmad-sg-terra.id]
}









