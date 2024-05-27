#-----------------------------------------------------------------------------------------
###### DATA BLOCK FOR EXISTING VPC ######
#-----------------------------------------------------------------------------------------
data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}
#-----------------------------------------------------------------------------------------
###### SUBNET GROUP CREATION ######
#-----------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group-${var.env}"
  subnet_ids = var.subnet_ids
}
#-----------------------------------------------------------------------------------------
###### RDS PARAMETER GROUP ######
#-----------------------------------------------------------------------------------------
resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "db-parameter-group-${var.env}"
  family      = var.db_parameter_group_family
  description = "My RDS Parameter Group description"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  # Add more parameters as needed
}
#-----------------------------------------------------------------------------------------
###### RDS SECURITY GROUP ######
#-----------------------------------------------------------------------------------------
resource "aws_security_group" "rds_security_group" {
  name        = "db-security-group-${var.env}"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.database_engine_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Adjust this as per your security requirements
    }
  }
}
#-----------------------------------------------------------------------------------------
###### RDS-PostgreSQL ######
#-----------------------------------------------------------------------------------------
resource "aws_db_instance" "rds_instance" {
  identifier                  = var.db_instance_identifier
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  username                    = var.db_username
  password                    = var.db_password
  allocated_storage           = var.storage
  publicly_accessible         = var.publicly_accessible
  skip_final_snapshot         = var.skip_final_snapshot
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_security_group.id]
  backup_retention_period     = var.backup_retention_period
  multi_az                    = var.multi_az
  storage_encrypted           = var.storage_encrypted
  storage_type                = var.storage_type
  iops                        = var.iops
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  character_set_name          = var.charset_name
  port                        = var.database_port
  parameter_group_name        = aws_db_parameter_group.rds_parameter_group.name
  db_name                     = var.db_name

  dynamic "restore_to_point_in_time" {
    for_each = var.snapshot_identifier == null && var.restore_to_point_in_time != null ? [1] : []

    content {
      restore_time                             = lookup(var.restore_to_point_in_time, "restore_time", null)
      source_db_instance_identifier            = lookup(var.restore_to_point_in_time, "source_db_instance_identifier", null)
      source_db_instance_automated_backups_arn = lookup(var.restore_to_point_in_time, "source_db_instance_automated_backups_arn", null)
      source_dbi_resource_id                   = lookup(var.restore_to_point_in_time, "source_dbi_resource_id", null)
      use_latest_restorable_time               = lookup(var.restore_to_point_in_time, "use_latest_restorable_time", null)
    }
  }

  depends_on = [
    aws_db_subnet_group.db_subnet_group,
    aws_security_group.rds_security_group,
    aws_db_parameter_group.rds_parameter_group,
  ]
  tags = var.tags
}
