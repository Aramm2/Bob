resource "aws_rds_cluster_instance" "aurora_cluster_instances" {
  count              = 1
  identifier         = "${var.project_name}-db-${var.env}-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_db.id
  instance_class     = var.cluster_instance_class
  engine             = aws_rds_cluster.aurora_db.engine
  engine_version     = aws_rds_cluster.aurora_db.engine_version
  publicly_accessible = true

  tags = merge(
    {
    "CostCenter"   = "${var.project_name}-db-${var.env}-${count.index}"
    "Name"         = "${var.project_name}-db-${var.env}-${count.index}"
  },
  var.map_tag
  )
}

resource "aws_rds_cluster" "aurora_db" {
  cluster_identifier      = "${var.project_name}-db-${var.env}"
  engine                  = var.engine
  engine_version          = var.engine_version
  availability_zones      = ["${var.region}a", "${var.region}b", "${var.region}c"]
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = 1
  skip_final_snapshot     = true
  apply_immediately       = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  tags = merge(
    {
    "CostCenter"   = "${var.project_name}-db-${var.env}"
    "Name"         = "${var.project_name}-db-${var.env}"
  },
  var.map_tag
  )
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}_vpc_${var.env}_rds_subnet"
  subnet_ids = var.public_subnet_list[*].id

  tags = merge(
    {Name = "RDS Aurora Subnet Group"},
    var.map_tag
  )
}

resource "aws_rds_cluster_parameter_group" "era_cluster_parameter_group" {
  name        = "${var.project_name}-aurora-mysql-8-pg"
  family      = var.cl_parameter_group_family
  description = "parameter group for ${var.project_name}-db"

  parameter {
    name  = "binlog_format"
    value = "ROW"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "lower_case_table_names"
    value = var.lower_case_table_names_values
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "aws_default_s3_role"
    value = aws_iam_role.aurora-input-output-role.arn
    apply_method = "pending-reboot"
  }
}

resource "aws_iam_role" "aurora-input-output-role" {
  name                = "aurora-input-output-role"
  assume_role_policy  = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "rds.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  )

  managed_policy_arns = [aws_iam_policy.aurora-input-output-policy.arn]
}

resource "aws_iam_policy" "aurora-input-output-policy" {
  name = "aurora-input-output-policy"

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::nebim-aurora-output/*", #TODO: output ve input bucket için s3 klasörüne eklemeler yapılmalı. daha sonra burası değişecek
                "arn:aws:s3:::nebim-aurora-output",
                "arn:aws:s3:::nebim-aurora-input/*",
                "arn:aws:s3:::nebim-aurora-input"
            ]
        }
    ]
}
  )
}
