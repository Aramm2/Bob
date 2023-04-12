module "vpc" {
  source       = "../modules/vpc"
  env          = var.env
  region       = var.region
  cidr_block   = var.cidr_block
  project_name = var.project_name
}
/*
module "documentdb" {
  source               = "../modules/documentdb"
  env                  = var.env
  project_name         = var.project_name
  docdb_security_group = module.vpc.docdb_security_group
  subnet_group_ids     = module.vpc.public_subnets
}


module "rds" {
  source             = "../modules/rds"
  env                = var.env
  project_name       = var.project_name
  public_subnet_list = module.vpc.public_subnets
  subnet_group_ids   = module.vpc.public_subnets
  rds_security_group   = module.vpc.rds_security_group
}


module "eks" {
  source          = "../modules/eks"
  env             = var.env
  region          = var.region
  project_name    = var.project_name
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "opensearch" {
  source            = "../modules/opensearch"
  env               = var.env
  region            = var.region
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = module.vpc.vpc_cidr_block
  vpc_default_security_group_id = module.vpc.vpc_default_security_group_id
  private_subnets   = module.vpc.private_subnets
  opensearch_domain = "${var.project_name}-opensearch-${var.env}"
}

module "aurora_mysql_db" {
  source             = "../modules/aurora"
  env                = var.env
  region             = var.region
  project_name       = var.project_name
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.02.0"
  database_name      = "era"
  master_username    = "admin"
  master_password    = "asdf1234"
  public_subnet_list = module.vpc.public_subnets
  account_id         = var.account_id
  cl_parameter_group_family = "aurora-mysql8.0"
  lower_case_table_names_values = "1"
  cluster_instance_class = "db.t3.medium"
}
*/
