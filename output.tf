output "s3_bucket_id" {
  description = "ID of S3 bucket used by Athena."
  value       = module.s3_module.s3_bucket_name
}

output "workgroup_id" {
  description = "ID of newly created Athena workgroup."
  value       = aws_athena_workgroup.athena_workgroup.id
}

output "databases" {
  description = "List of newly created Athena databases."
  value       = aws_athena_database.athena_database
}

output "data_catalogs" {
  description = "List of newly created Athena data catalogs."
  value       = aws_athena_data_catalog.data_catalog
}

output "named_queries" {
  description = "List of newly created Athena named queries."
  value       = aws_athena_named_query.queries
}