
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  #vpc_id = var.vpc_id
  #ids=["subnet-0f0d2d206d8416d360","subnet-0c096ceddc03701ce","subnet-035aa91ea1a6f9ef8"]
  filter {
    name = "tag:Type"
    values = ["private"]
  }
}

data "aws_route_table" "selected" {
  for_each  = toset(data.aws_subnets.private.ids)
  subnet_id = each.value
}

#create dns name
resource "aws_service_discovery_private_dns_namespace" "private_dns" {
  name        = "${var.name_prefix}-dns"
  description = "service discovery endpoint"
  vpc         = var.vpc_id
  tags        = var.default_tags
}

#attach dns name to ecsservice discovery
resource "aws_service_discovery_service" "service_discovery" {
  name = "${var.name_prefix}-discovery"
  tags = var.default_tags
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 3
  }
}

#create ecr repo for ecs docker images
resource "aws_ecr_repository" "ecr" {
  name                 = "${var.name_prefix}-discovery"
  image_tag_mutability = "MUTABLE"
  tags                 = var.default_tags
  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecs_cluster" "sidecar" {
  name = "${var.name_prefix}-cluster"
  tags               = var.default_tags
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "sidecar" {
  cluster_name = aws_ecs_cluster.sidecar.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


# resource "aws_ecs_cluster" "sidecar" {
#   name               = "${var.name_prefix}-cluster"
#   aws_ecs_cluster_capacity_providers = ["FARGATE"]
#   tags               = var.default_tags
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }



#create ecs service and bind to cluster for manager
resource "aws_ecs_service" "sidecar" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.sidecar.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.sidecar_security_group.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.service_discovery.arn
    container_name = "${var.name_prefix}-task"
    container_port = var.controller_port
  }
}

