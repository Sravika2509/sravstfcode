# Create Event Bus
resource "aws_cloudwatch_event_bus" "cloudwatch_event_bus_infra_prov" {
  name = var.event_bus_name
}

# Create Lambda function code archive
data "archive_file" "lambda_function_code" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"

  source {
    content  = <<-EOF
      // Your Lambda function code here
      exports.test = async (event) => {
        console.log("Lambda function executed!");
      };
    EOF
    filename = "index.js"
  }
}

# Create IAM Role for Lambda
resource "aws_iam_role" "iam_for_lambda_infra_prov" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

# Create IAM Policy for Lambda and SQS full access
resource "aws_iam_policy" "lambda_sqs_full_access_policy" {
  name        = "LambdaSQSFullAccessPolicy"
  description = "Policy granting full access to Lambda functions and SQS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["lambda:*"],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = ["sqs:*"],
        Resource = aws_sqs_queue.sqs_queue_infra_prov.arn,
      },
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_sqs_full_access_attachment" {
  policy_arn = aws_iam_policy.lambda_sqs_full_access_policy.arn
  role       = aws_iam_role.iam_for_lambda_infra_prov.name
}

# Create Lambda function
resource "aws_lambda_function" "lambda_function_infra_prov" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda_infra_prov.arn
  handler       = "index.test"
  filename      = data.archive_file.lambda_function_code.output_path
  runtime       = "nodejs20.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# Create CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule_infra_prov" {
  name        = var.event_rule_name
  description = var.event_rule_description

  event_pattern = var.event_pattern
}

# Create CloudWatch Event Target for Lambda
resource "aws_cloudwatch_event_target" "cloudwatch_event_target_infra_prov" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_event_rule_infra_prov.name
  target_id = var.event_target_id
  arn       = aws_lambda_function.lambda_function_infra_prov.arn
}

# Allow CloudWatch Events to trigger Lambda
resource "aws_lambda_permission" "lambda_permission_infra_prov" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_infra_prov.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.cloudwatch_event_rule_infra_prov.arn
}

# Create CloudWatch Event Connection with BASIC authorization (empty auth_parameters block)
resource "aws_cloudwatch_event_connection" "cloudwatch_event_connection_infra_prov" {
  name               = var.connection_name_none
  description        = var.connection_description_none
  authorization_type = var.authorization_type

  auth_parameters {
    basic {
      username = var.username  
      password = var.password 
    }
  }
}

# Create AWS Pipes Pipe with EventBridge Event Bus as the target
resource "aws_pipes_pipe" "pipes_pipe_infra_prov" {
  name        = var.pipe_name
  description = var.pipe_description
  role_arn    = aws_iam_role.iam_for_pipes_pipe_infra_prov.arn  # Use the IAM role ARN
  source      = aws_sqs_queue.sqs_queue_infra_prov.arn  # Use the ARN of the SQS Queue as the source
  target      = aws_cloudwatch_event_bus.cloudwatch_event_bus_infra_prov.arn  # Use the ARN of the Event Bus as the target
}

# Update AWS Lambda Permission for EventBridge
resource "aws_lambda_permission" "lambda_permission_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_infra_prov.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_bus.cloudwatch_event_bus_infra_prov.arn
}

# Create SQS Queue
resource "aws_sqs_queue" "sqs_queue_infra_prov" {
  name                      = var.sqs_queue_name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
}

# Update IAM Role for pipes_pipe
resource "aws_iam_role" "iam_for_pipes_pipe_infra_prov" {
  name = "pipes_pipe_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "pipes.amazonaws.com"  # Update with the correct service name for pipes
        },
        Effect = "Allow"
      }
    ]
  })
}


# Create IAM Policy for Amazon EventBridge Pipes
resource "aws_iam_policy" "pipes_pipe_policy" {
  name        = "AmazonEventBridgePipesPolicy"
  description = "Policy granting necessary permissions for Amazon EventBridge Pipes"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",  # Add other necessary SQS permissions as needed
          # Add other necessary permissions for Amazon EventBridge Pipes
        ],
        Resource = [
          aws_sqs_queue.sqs_queue_infra_prov.arn,
          # Add other necessary resource ARNs
        ],
      },
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "pipes_pipe_policy_attachment" {
  policy_arn = aws_iam_policy.pipes_pipe_policy.arn
  role       = aws_iam_role.iam_for_pipes_pipe_infra_prov.name
}

# ...

# Update IAM Role for AWS EventBridge Scheduler
resource "aws_iam_role" "iam_for_scheduler_infra_prov" {
  name = "eventbridge-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "scheduler.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

# Attach IAM Policy to IAM Role for AWS EventBridge Scheduler
resource "aws_iam_role_policy_attachment" "scheduler_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"  # Assuming you want to use the AWSLambdaRole, adjust as needed
  role       = aws_iam_role.iam_for_scheduler_infra_prov.name
}

# Create Scheduler Schedule Group
resource "aws_scheduler_schedule_group" "scheduler_schedule_group_infra_prov" {
  name = var.schedule_group_name
}

# Create Scheduler Schedule with AWS Pipes Pipe as the target
resource "aws_scheduler_schedule" "scheduler_schedule_infra_prov" {
  name                = var.schedule_name
  schedule_expression = "rate(1 day)"  
  group_name          = aws_scheduler_schedule_group.scheduler_schedule_group_infra_prov.name    

  flexible_time_window {
    mode = "OFF"  # Adjust as needed
  }

  target {
    arn      = aws_lambda_function.lambda_function_infra_prov.arn
    role_arn = aws_iam_role.iam_for_scheduler_infra_prov.arn
  }
}
