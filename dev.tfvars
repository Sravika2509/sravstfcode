#region specifies the AWS region
region = "ap-southeast-1"

#athena_s3_bucket_name specifies the root bucket name
athena_s3_bucket_name = "my-athena-bucket"

#force_destroy_s3 specifies whether to force destroy the bucket
force_destroy = true

#athena_s3_bucket_tags specifies the tags associated with the provisioned bucket
athena_s3_bucket_tags = {
  owner = "TigerAnalytics"
}

#athena-name specifies the name for the Athena resource
athena-name = "TigerAnalytics-Athena-WCR3"

#enable-athena-force-destroy specifies whether to enable force destroy of Athena tables during destroy
enable-athena-force-destroy = true

#athena-comment specifies the comment to display along with the provisioned Athena resource
athena-comment = "TigerAnalytics-Athena"

#athena-encryption-config specifies the key config Athena uses to decrypt data in S3
athena-encryption-config = "SSE_S3"

#workgroup_name specifies the name of the Athena workgroup
workgroup_name = "my-athena-workgroup"

#requester_pays specifies whether the workgroup should pay for query execution
requester_pays = false

# create_kms_key specifies whether to create a KMS key for Athena workgroup
create_kms_key = true

# athena_kms_key specifies an existing KMS key for Athena
athena_kms_key                 = null
athena_kms_key_deletion_window = 7
kms_key_description            = "KMS key for Athena"

#workgroup_description specifies the description of the Athena workgroup
workgroup_description = ""

#bytes_scanned_cutoff_per_query specifies the cutoff for bytes scanned per query
bytes_scanned_cutoff_per_query = null

#enforce_workgroup_configuration specifies whether workgroup settings override client-side settings
enforce_workgroup_configuration = true

#publish_cloudwatch_metrics_enabled specifies whether CloudWatch metrics are enabled for the workgroup
publish_cloudwatch_metrics_enabled = true

#workgroup_encryption_option specifies the encryption option for the workgroup
workgroup_encryption_option = "SSE_KMS"

#s3_output_path specifies the S3 bucket path used to store query results
s3_output_path = "athena-outputs"

#workgroup_state specifies the state of the workgroup
workgroup_state = "ENABLED"

#workgroup_force_destroy specifies whether to force destroy the workgroup and its contents
workgroup_force_destroy = true

#databases specifies Athena databases and related configuration
databases = {
  database1 = {
    name    = "database1"
    comment = "This is database 1"
    properties = {
      key1 = "value1"
      key2 = "value2"
    }
    acl_configuration = {
      s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
    }
    expected_bucket_owner = null
    force_destroy         = true
  }
}


# Define the data catalogs
/*
-----name-----
"(Required) The name of the data catalog. The catalog name must be unique for the AWS account and can use a maximum of 128 alphanumeric, underscore, at sign, or hyphen characters."
------type----
(Required) A type of the data catalog. Valid values are `LAMBDA`, `GLUE`, `HIVE`.
    - `LAMBDA` for a federated catalog.
    - `GLUE` for an AWS Glue Data Catalog.
    - `HIVE` for an external hive metastore.
----
(Optional) A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. The mapping used depends on the catalog type.

  `LAMBDA`
    Use one of the following sets of required parameters, but not both.
    - If you have one Lambda function that processes metadata and another for reading the actual data.
      (Required) `metadata-function` - The ARN of Lambda function to process metadata.
      (Required) `record-function` - The ARN of Lambda function to read the actual data.
    - If you have a composite Lambda function that processes both metadata and data.
      (Required) `function` - The ARN of a composite Lambda function to process both metadata and data.

  `GLUE`
    (Required) `catalog-id` - The account ID of the AWS account to which the Glue Data Catalog belongs.

  `HIVE`
    (Required) `metadata-function` - The ARN of Lambda function to process metadata.
    (Optional) `sdk-version` - Defaults to the currently supported version.
*/

data_catalogs = {
  catalog1 = {
    name        = "catalog1"
    description = "Data catalog 1"
    type        = "GLUE"
    parameters = {
      catalog-id = ""
    }
  }
}

# Define the named queries
named_queries = {
  query1 = {
    name        = "query1"
    database    = "database1"
    query       = "SELECT * FROM database1"
    description = "Named query 1"
  }
}
tags = {
  Environment = "dev"
  created_for = "dac"
  created_by  = "terraform"
}

#Cloudwatch
query_queue_time_threshold_seconds      = 60
query_processing_time_threshold_seconds = 60
cloudwatch_resources                    = true
dashboard_name                          = "Athena-Dashboard"
sns_topic_name                          = "CloudWatch_Notifications_athena"



