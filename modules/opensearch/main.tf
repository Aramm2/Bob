resource "aws_security_group" "opensearch_sg" {
  name        = "opensearch-sg"
  description = "Allow inbound traffic to OpenSearch"
  vpc_id      = var.vpc_id

  ingress {
    description      = "EKS SG"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [var.vpc_default_security_group_id]
  }
  ingress {
    description      = "VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr_block]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "opensearch-sg"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "opensearch_linked_role" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name    = var.opensearch_domain
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type          = "t3.medium.search"
    instance_count = 1
    zone_awareness_enabled = false
  }

  vpc_options {
    subnet_ids = [var.private_subnets[0].id]

    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
  auto_tune_options {
    desired_state = "DISABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain}/*"
    }
  ]
}
CONFIG

  tags = merge(
    {Domain = "${var.project_name}-opensearch-${var.env}"},
    var.map_tag
  )

  depends_on = [aws_iam_service_linked_role.opensearch_linked_role]
}