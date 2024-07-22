variable "event_bus_name" {
  description = "Name of the CloudWatch Event Bus"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM Role for Lambda"
  type        = string
}

variable "event_rule_name" {
  description = "Name of the CloudWatch Event Rule"
  type        = string
}

variable "event_rule_description" {
  description = "Description of the CloudWatch Event Rule"
  type        = string
}

variable "event_pattern" {
  description = "Event pattern for the CloudWatch Event Rule"
  type        = string
}

variable "event_target_id" {
  description = "ID for the CloudWatch Event Target"
  type        = string
}

variable "connection_name" {
  description = "Name for the CloudWatch Event Connection"
  type        = string
}

variable "connection_description" {
  description = "Description for the CloudWatch Event Connection"
  type        = string
}

variable "destination_name" {
  description = "Name for the CloudWatch Event Destination"
  type        = string
}

variable "destination_description" {
  description = "Description for the CloudWatch Event Destination"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "connection_name_none" {
  description = "CloudWatch Event Connection Name"
  type        = string
}

variable "connection_description_none" {
  description = "CloudWatch Event Description Name"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "api_resource_path_part" {
  description = "Path part for the API Gateway resource"
  type        = string
}

variable "api_http_method" {
  description = "HTTP method for the API Gateway method"
  type        = string
}

variable "api_stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
}

variable "pipe_name" {
  description = "Name of the EventBridge Pipe"
  type        = string
}

variable "schedule_group_name" {
  description = "Name of the EventBridge Schedule Group"
  type        = string
}

variable "schedule_name" {
  description = "Name of the EventBridge Schedule"
  type        = string
}

variable "pipe_description" {
  description = "Description of the EventBridge Pipe"
  type        = string
  default     = "Your default description for the pipe"
}

variable "schedule_description" {
  description = "Description of the EventBridge Schedule"
  type        = string
  default     = "Your default description for the schedule"
}

variable "sqs_queue_name" {
  description = "Name of the SQS Queue"
  type        = string
}

variable "authorization_type" {
  description = "Authorization type for CloudWatch Event Connection"
  type        = string
}

variable "username" {
  description = "Username for CloudWatch Event Connection BASIC authorization"
  type        = string
}

variable "password" {
  description = "Password for CloudWatch Event Connection BASIC authorization"
  type        = string
}

variable "delay_seconds" {
  description = "Delay in seconds for SQS Queue"
  type        = number
}

variable "max_message_size" {
  description = "Maximum message size for SQS Queue"
  type        = number
}

variable "message_retention_seconds" {
  description = "Seconds parameter (update the description as needed)"
  type        = number
}