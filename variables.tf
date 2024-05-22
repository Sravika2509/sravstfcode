variable "parametername" {
  description = "Name of the parameter"
  type        = string
  default     = "default_parameter_name"
}

variable "parametervalue" {
  description = "Value of the parameter"
  type        = string
  default     = "default_parameter_value"
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be deployed"
  type        = string
  default     = "vpc-0f95b0003a8f3b723"
}

variable "db_instance_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "my-rds-instance"
}

variable "db_engine" {
  description = "Database engine type (e.g., MariaDB, MySQL, PostgreSQL)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "15.6"
}

variable "storage" {
  description = "Allocated storage for the RDS instance (in GB)"
  type        = string
  default     = "20"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  default     = "Tiger123"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
  default     = ["subnet-0dcc687f316c00a89", "subnet-0319afd980978b59a"]
}

variable "database_engine_ports" {
  description = "Mapping of database engine types to their default ports"
  type        = map(number)
  default = {
    "postgresql" = 5432
  }
}

variable "database_port" {
  description = "Port number for database access"
  type        = number
  default     = 5432
}

variable "charset_name" {
  description = "Character set name used for database encoding"
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres15"
}

variable "snapshot_identifier" {
  description = "Identifier of the snapshot to restore from"
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Object specifying the restore point in time for the DB instance"
  type = object({
    restore_time                             = optional(string, null)
    source_db_instance_identifier            = optional(string, null)
    source_db_instance_automated_backups_arn = optional(string, null)
    source_dbi_resource_id                   = optional(string, null)
    use_latest_restorable_time               = optional(bool, null)
  })
  default = null
}

variable "audit_plugin_server_audit_events" {
  description = "Events to be audited by the server audit plugin"
  type        = string
  default     = "CONNECT,QUERY,TABLE"
}

variable "storage_type" {
  description = "Type of storage (e.g., gp2, io1)"
  type        = string
  default     = "gp2"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades for the database engine"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades for the database engine"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Make the RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip creating a final snapshot when deleting the database instance"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = string
  default     = "7"
}

variable "tags" {
  description = "Mapping of tags to be assigned to resources"
  type        = map(string)
  default     = {}
}