
variable "region" {
  type = string
}
variable "athena_s3_bucket_name" {
  type = string
  description = "Root bucket name"
}

variable "force_destroy" {
  type = bool
  description = "Force destroy the bucket"
  default = true
}

variable "athena_s3_bucket_tags" {
  type = map(string)
  description = "List of tags to be associated with the provisioned bucket."
  default = {
    owner = "TigerAnalytics"
  }
}
variable "athena-name" {
  type = string
  description = "Name for the athena resource that is to be provisioned."
  default = "TigerAnalytics-Athena-WCR3"
}

variable "enable-athena-force-destroy" {
  type = bool
  description = "Flag to enable or disable force destroy athena tables at the time of destroy."
  default = false
}

variable "athena-comment" {
  type = string
  description = "Comment to display along with provisioned athena resource."
  default = "TigerAnalytics-Athena"
}

variable "athena-encryption-config" {
  type = string
  description = "Key config athena uses to decrypt data in S3."
  default = "SSE_S3"
}

variable "workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "requester_pays" {
  description = "Whether the workgroup should be configured to pay for query execution"
  type        = bool
}


###athena
variable "create_kms_key" {
  description = "Enable the creation of a KMS key used by Athena workgroup."
  type        = bool
  default     = true
}

variable "athena_kms_key" {
  description = "Use an existing KMS key for Athena if `create_kms_key` is `false`."
  type        = string
  default     = null
}
variable "kms_key_description" {
  type = string
  description = "KMS key description"
  default = "KMS for glue"
}

variable "athena_kms_key_deletion_window" {
  description = "KMS key deletion window (in days)."
  type        = number
  default     = 7
}

variable "workgroup_description" {
  description = "A description the of Athena workgroup."
  type        = string
  default     = ""
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Integer for the upper data usage limit (cutoff) for the amount of bytes a single query in a workgroup is allowed to scan. Must be at least 10485760."
  type        = number
  default     = null
}

variable "enforce_workgroup_configuration" {
  description = "Boolean whether the settings for the workgroup override client-side settings."
  type        = bool
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Boolean whether Amazon CloudWatch metrics are enabled for the workgroup."
  type        = bool
}

variable "workgroup_encryption_option" {
  description = "Indicates whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE_S3), server-side encryption with KMS-managed keys (SSE_KMS), or client-side encryption with KMS-managed keys (CSE_KMS) is used."
  type        = string
  default     = "SSE_KMS"
}

variable "s3_output_path" {
  description = "The S3 bucket path used to store query results."
  type        = string
  default     = ""
}

variable "workgroup_state" {
  description = "State of the workgroup. Valid values are `DISABLED` or `ENABLED`."
  type        = string
  default     = "ENABLED"
}

variable "workgroup_force_destroy" {
  description = "The option to delete the workgroup and its contents even if the workgroup contains any named queries."
  type        = bool
  default     = false
}

/*variable "databases" {
  description = "Map of Athena databases and related configuration."
  type        = map(any)
}*/
variable "databases" {
  description = "Map of Athena databases and related configuration."
  type        = map(object({
    name                     = string
    comment                  = string
    properties               = map(string)
    acl_configuration        = object({
      s3_acl_option = string
    })
    expected_bucket_owner   = string
    force_destroy           = bool
  }))
}
variable "data_catalogs" {
  description = "Map of Athena data catalogs and related configuration."
  type        = map(any)
}

variable "named_queries" {
  description = "Map of Athena named queries and related configuration."
  type        = map(map(string))
}

variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to be applied to the kinesis stream"
}

variable "s3_cloudwatch_resources" {
  description = "Flag to enable/disable creation of CloudWatch alarms for S3 buckets"
  type        = bool
  default     = false
}

variable "cloudwatch_resources" {
  description = "Set to true to create CloudWatch resources, false otherwise"
  type        = bool
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarm notifications"
  type        = string
  default     = "CloudWatch_Notifications_athena"
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "Athena-Dashboard"
}

variable "query_queue_time_threshold_seconds" {
  description = "Threshold for query queue time in seconds"
  type        = number
  default     = 60
}

variable "query_processing_time_threshold_seconds" {
  description = "Threshold for query processing time in seconds"
  type        = number
  default     = 60
}
