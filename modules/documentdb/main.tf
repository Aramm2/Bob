resource "aws_docdb_cluster" "smartfind_docdb_cluster" {
  cluster_identifier     = "${var.project_name}-docdb-cluster-${var.env}"
  master_username        = jsondecode(data.aws_secretsmanager_secret_version.docdb_current_secrets.secret_string)["username"]
  master_password        = jsondecode(data.aws_secretsmanager_secret_version.docdb_current_secrets.secret_string)["password"]
  kms_key_id             = aws_kms_key.docdb_key.arn
  storage_encrypted      = true
  vpc_security_group_ids = [var.docdb_security_group]
  db_subnet_group_name   = aws_db_subnet_group.docdb_subnet_group.name
  skip_final_snapshot    = true
}

resource "aws_docdb_cluster_instance" "smartfind_docdb_instance" {
  identifier         = "${var.project_name}-docdb-instance-${var.env}"
  cluster_identifier = aws_docdb_cluster.smartfind_docdb_cluster.id
  instance_class     = "db.t3.medium"
}

resource "aws_db_subnet_group" "docdb_subnet_group" {
  name       = "${var.project_name}-vpc-rds-subnet-${var.env}"
  subnet_ids = var.subnet_group_ids[*].id

  tags = merge(
    { Name = "documentDB ${var.project_name} subnet group" }
  )
}

resource "aws_kms_key" "docdb_key" {
  description             = "${var.project_name} documentDB key"
  deletion_window_in_days = 30
}

resource "aws_secretsmanager_secret" "docdb_secrets_manager" {
  name = "${var.project_name}-docdb-configure-${var.env}"
}

resource "aws_secretsmanager_secret_version" "docdb_sv" {
  secret_id     = aws_secretsmanager_secret.docdb_secrets_manager.id
  secret_string = jsonencode(var.docdb_configure)
}

data "aws_secretsmanager_secret" "docdb_env_secrets" {
  name = "${var.project_name}-docdb-configure-${var.env}"
  depends_on = [
    aws_secretsmanager_secret.docdb_secrets_manager
  ]
}

data "aws_secretsmanager_secret_version" "docdb_current_secrets" {
  secret_id = data.aws_secretsmanager_secret.docdb_env_secrets.id
}

