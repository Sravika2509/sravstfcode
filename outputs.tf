output "event_bus_arn" {
  description = "The ARN of the CloudWatch Event Bus"
  value       = aws_cloudwatch_event_bus.cloudwatch_event_bus_infra_prov.arn
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function_infra_prov.arn
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.cloudwatch_event_rule_infra_prov.arn
}

output "cloudwatch_event_connection_arn" {
  description = "The ARN of the CloudWatch Event Connection"
  value       = aws_cloudwatch_event_connection.cloudwatch_event_connection_infra_prov.arn
}

output "event_bridge_pipe_arn" {
  description = "The ARN of the EventBridge Pipe"
  value       = aws_pipes_pipe.pipes_pipe_infra_prov.arn
}

output "event_bridge_schedule_group_name" {
  description = "The name of the EventBridge Schedule Group"
  value       = aws_scheduler_schedule_group.scheduler_schedule_group_infra_prov.name
}

output "event_bridge_schedule_name" {
  description = "The name of the EventBridge Schedule"
  value       = aws_scheduler_schedule.scheduler_schedule_infra_prov.name
}
