resource "aws_rds_cluster" "smartfind_postgresql_rds_cluster" {
  cluster_identifier     = "${var.project_name}-cluster-${var.env}"
  engine                 = "aurora-postgresql"
  engine_version         = "14.6"
  database_name          = var.project_name
  master_username        = jsondecode(data.aws_secretsmanager_secret_version.rds_current_secrets.secret_string)["username"]
  master_password        = jsondecode(data.aws_secretsmanager_secret_version.rds_current_secrets.secret_string)["password"]
  kms_key_id             = aws_kms_key.rds_key.arn
  storage_encrypted      = true
  vpc_security_group_ids = [var.rds_security_group]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "smartfind_postgresql_rds_instance" {
  apply_immediately  = true
  cluster_identifier = aws_rds_cluster.smartfind_postgresql_rds_cluster.id
  engine             = aws_rds_cluster.smartfind_postgresql_rds_cluster.engine
  engine_version     = aws_rds_cluster.smartfind_postgresql_rds_cluster.engine_version
  identifier         = "${var.project_name}-rds-instance-${var.env}"
  instance_class     = "db.r5.large"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-vpc-rds-subnet-${var.env}"
  subnet_ids = var.public_subnet_list[*].id

  tags = merge(
    { Name = "RDS Aurora Subnet Group" }
  )
}
resource "aws_kms_key" "rds_key" {
  description             = "${var.project_name} rds key"
  deletion_window_in_days = 30
}

resource "aws_secretsmanager_secret" "rds_secrets_manager" {
  name = "${var.project_name}-rds-configure-${var.env}"
}

resource "aws_secretsmanager_secret_version" "rds_sv" {
  secret_id     = aws_secretsmanager_secret.rds_secrets_manager.id
  secret_string = jsonencode(var.rds_configure)
}

data "aws_secretsmanager_secret" "rds_env_secrets" {
  name = "${var.project_name}-rds-configure-${var.env}"
  depends_on = [
    aws_secretsmanager_secret.rds_secrets_manager
  ]
}

data "aws_secretsmanager_secret_version" "rds_current_secrets" {
  secret_id = data.aws_secretsmanager_secret.rds_env_secrets.id
}
