resource "aws_ecs_cluster" "essentia-web-cluster" {
  name = "essentia-web-cluster"
}

data "template_file" "essentia-web" {
  template = file("./templates/image/image.json")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = "ap-northeast-1"
  }
}

resource "aws_ecs_task_definition" "essentia-web-def" {
  family                   = "essentia-web-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.essentia-web.rendered
}

resource "aws_ecs_service" "essentia-web-service" {
  name            = "essentia-web-service"
  cluster         = aws_ecs_cluster.essentia-web-cluster.id
  task_definition = aws_ecs_task_definition.essentia-web-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.essentia-web-tg.arn
    container_name   = "essentia-web"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.essentia-web, aws_iam_role_policy_attachment.ecs_task_execution_role]
}