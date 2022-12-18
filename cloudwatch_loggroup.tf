# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "essentia-web_log_group" {
  name              = "/ecs/essentia-web"
  retention_in_days = 30

  tags = {
    Name = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "essentia-web_log_stream" {
  name           = "essentia-web-log-stream"
  log_group_name = aws_cloudwatch_log_group.essentia-web_log_group.name
}