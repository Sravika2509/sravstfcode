#Rds-PostgreSQL Variables
region                 = "ap-southeast-1"
env                    = "dev"
vpc_id                 = "vpc-03290bf9c73463418"
parametername          = "rds.force_ssl"
parametervalue         = "0"
db_instance_identifier = "my-rds-instance"
db_engine              = "postgres"
db_engine_version      = "16.2"
storage                = "100"
db_instance_class      = "db.m5d.xlarge"
db_username            = "myadmin"  # Change this as per your existing naming convention
db_password            = "Tiger123"  # Change this as per your existing naming convention
subnet_ids             = ["subnet-0cfd1ddb744c6ba44", "subnet-04245c28f1f564848"]
database_engine_ports = {
  postgresql = 5432
}
database_port                    = 5432
db_parameter_group_family        = "postgres16"
charset_name                     = null
snapshot_identifier              = null
restore_to_point_in_time         = null
tags                             = { Environment = "dev" }
db_name                          = "dynamofl"
iops                             = 1000
