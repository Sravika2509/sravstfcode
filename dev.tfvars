#Rds-PostgreSQL Variables
region                 = "ap-southeast-1"
env                    = "dev"
vpc_id                 = "vpc-0a6cf673aa37f41b2"
parametername          = "log_statement"
parametervalue         = "all"
db_instance_identifier = "my-rds-instance"
db_engine              = "postgres"
db_engine_version      = "15.6"
storage                = "20"
db_instance_class      = "db.t3.micro"
db_username            = "myadmin"
db_password            = "Tiger123"
subnet_ids             = ["subnet-065684815f2dd01d8", "subnet-03bfb0c575866eb1e"]
database_engine_ports = {
  postgresql = 5432
}
database_port                    = 5432
db_parameter_group_family        = "postgres15"
charset_name                     = null
snapshot_identifier              = null
restore_to_point_in_time         = null
audit_plugin_server_audit_events = "CONNECT,QUERY,TABLE"
tags                             = { Environment = "dev" }