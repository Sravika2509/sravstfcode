module "s3_module" {
    source = "../s3"
    s3_bucket_name = var.athena_s3_bucket_name
    region = var.region
    force_destroy = var.force_destroy
    tags = var.athena_s3_bucket_tags
    cloudwatch_resources = var.s3_cloudwatch_resources
  }

data "aws_iam_policy_document" "athena-bucket-policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["athena.amazonaws.com"]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      module.s3_module.s3_bucket_arn,
      "${module.s3_module.s3_bucket_arn}/*",
    ]
  }
}
resource "aws_s3_bucket_policy" "athena_bucket_policy" {
  bucket = module.s3_module.s3_bucket_name
  policy = data.aws_iam_policy_document.athena-bucket-policy.json
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = var.workgroup_name

  configuration {
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    
    result_configuration {
      output_location = format("s3://%s/%s", module.s3_module.s3_bucket_name, var.s3_output_path)
    }
  }
  force_destroy = var.workgroup_force_destroy
  state         = var.workgroup_state 
  tags = var.tags
}

resource "aws_athena_database" "athena_database" {
  for_each = { for idx, db in var.databases : idx => db }

  name       = each.value.name
  bucket     = module.s3_module.s3_bucket_name
  comment    = each.value.comment
  properties = each.value.properties
  

  dynamic "acl_configuration" {
    for_each = each.value.acl_configuration != null ? ["true"] : []

    content {
      s3_acl_option = each.value.acl_configuration.s3_acl_option
    }
  }
  expected_bucket_owner = each.value.expected_bucket_owner
  force_destroy         = each.value.force_destroy
  
}
data "aws_caller_identity" "current" {}
resource "aws_athena_data_catalog" "data_catalog" {
  for_each = { for idx, catalog in var.data_catalogs : idx => catalog }

  name        = "${each.value.name}"
  description = each.value.description
  type        = each.value.type

  parameters =  each.value.type == "GLUE" ? merge(
    each.value.parameters,
    each.value.parameters.catalog-id != "" ? { "catalog-id" = "${each.value.parameters.catalog-id}" } : { "catalog-id" = "${data.aws_caller_identity.current.account_id}" }
  ): each.value.parameters
  

  tags = var.tags
}

resource "aws_athena_named_query" "queries" {
for_each = var.named_queries

  name        = each.value.name
  workgroup   = aws_athena_workgroup.athena_workgroup.name
  database    = aws_athena_database.athena_database[each.value.database].name
  query       = each.value.query
  description = each.value.description
}

## Cloudwatch Alarms and Metrics Dashboard 
resource "aws_sns_topic" "cloudwatch_notifications" {
  count = var.cloudwatch_resources ? 1 : 0
  name  = var.sns_topic_name
}

resource "aws_cloudwatch_metric_alarm" "athena_query_queue_time_alarm" {
  count = var.cloudwatch_resources ? 1 : 0
  alarm_name          = "AthenaQueryQueueTimeAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "QueryQueueTime"
  namespace           = "AWS/Athena"
  period              = 300
  statistic           = "Average"
  threshold           = var.query_queue_time_threshold_seconds
  alarm_description   = "Alarm when query queue time exceeds 60 seconds"
  alarm_actions       = var.cloudwatch_resources ? [aws_sns_topic.cloudwatch_notifications[0].arn] : []
  dimensions = {
    WorkGroup = aws_athena_workgroup.athena_workgroup.id
  }
  depends_on = [aws_athena_workgroup.athena_workgroup]
}

resource "aws_cloudwatch_metric_alarm" "athena_query_processing_time_alarm" {
  count = var.cloudwatch_resources ? 1 : 0
  alarm_name          = "AthenaQueryProcessingTimeAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ServiceProcessingTime"
  namespace           = "AWS/Athena"
  period              = 300
  statistic           = "Average"
  threshold           = var.query_processing_time_threshold_seconds
  alarm_description   = "Alarm when query processing time exceeds 60 seconds"
  alarm_actions       = var.cloudwatch_resources ? [aws_sns_topic.cloudwatch_notifications[0].arn] : []
  dimensions = {
    WorkGroup = aws_athena_workgroup.athena_workgroup.id
  }
  depends_on = [aws_athena_workgroup.athena_workgroup]
}

resource "aws_cloudwatch_dashboard" "athena_dashboard" {
  count          = var.cloudwatch_resources ? 1 : 0
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    "widgets" : [
     ## Athena Metrics
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "title" : "Athena Query Queue Time",
          "stacked" : false,
          "metrics" : [
            ["AWS/Athena", "QueryQueueTime", "WorkGroup", "${aws_athena_workgroup.athena_workgroup.id}"]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "title" : "Athena Query Processing Time",
          "stacked" : false,
          "metrics" : [
            ["AWS/Athena", "ServiceProcessingTime", "WorkGroup", "${aws_athena_workgroup.athena_workgroup.id}"]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "view" : "timeSeries",
          "title" : "Athena DPU Allocated",
          "stacked" : false,
          "metrics" : [
            ["AWS/Athena", "DPUAllocated", "WorkGroup", "${aws_athena_workgroup.athena_workgroup.id}"]
          ],
          "region" : "${var.region}"
        }
      }
    ]
  })
  depends_on = [aws_athena_workgroup.athena_workgroup]
}
