
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_identifier

  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = var.monitoring_role_name
  create_monitoring_role = var.create_monitoring_role

  tags = var.tags

  create_db_subnet_group = var.create_db_subnet_group
  subnet_ids             = var.subnet_ids
  family                 = var.db_family
  major_engine_version   = var.db_major_engine_version
  allow_major_version_upgrade = true

  deletion_protection = var.deletion_protection

  parameters = var.db_parameters

  options = var.db_options
}
