resource "aws_cognito_user_pool" "pool" {

  name = "${var.project_name}-user-pool-${var.env}"
  username_attributes = [ "email" ]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message = "${var.project_name} için doğrulama kodunuz : {####}. "
    email_subject = "${var.project_name} Doğrulama Kodu"
  }

  tags = merge(
    {
    "CostCenter"   = "${var.project_name}-user-pool-${var.env}"
    "Name"         = "${var.project_name}-user-pool-${var.env}"
  },
    var.tags
  )

  schema {
    name = "TenantId"
    attribute_data_type = "String"
    mutable = true
    string_attribute_constraints {   
      min_length = 0                 
      max_length = 256              
    }
  }

  schema {
    name = "UserId"
    attribute_data_type = "String"
    mutable = true
    string_attribute_constraints {   
      min_length = 0                 
      max_length = 256              
    }
  }

  schema {
    name = "StoreId"
    attribute_data_type = "String"
    mutable = true
    string_attribute_constraints {   
      min_length = 0                 
      max_length = 256              
    }
  }

  password_policy {
    minimum_length = 6
    require_lowercase = true
    require_numbers = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  mfa_configuration          = "OFF"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
  auto_verified_attributes = ["email"]

}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-app-user-pool-${var.env}"
  user_pool_id = aws_cognito_user_pool.pool.id
}


resource "aws_cognito_user_pool_client" "client" {

  name                              = "${var.project_name}-cognito-client-${var.env}"
  user_pool_id                      = "${aws_cognito_user_pool.pool.id}"
  enable_token_revocation           = true
  supported_identity_providers      = ["COGNITO"]
  generate_secret                   = false
  refresh_token_validity            = 1 #hour
  access_token_validity             = 1 #hour
  id_token_validity                 = 1 #hour
  token_validity_units {
    access_token = "hours"
    id_token = "hours"
    refresh_token = "hours"
  }
  prevent_user_existence_errors        = "ENABLED"
  explicit_auth_flows                  = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  read_attributes                      = ["custom:TenantId", "custom:UserId", "custom:StoreId"]
  write_attributes                     = ["custom:TenantId", "custom:UserId", "custom:StoreId"]
  callback_urls                        = var.cognito_callback_urls
  logout_urls                          = var.cognito_logout_urls
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "aws.cognito.signin.user.admin", "profile"]
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-identity-pool-${var.env}"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.client.id
    provider_name = "cognito-idp.us-central-1.amazonaws.com/${aws_cognito_user_pool.pool.id}"
    server_side_token_check = false
  }
}

resource "aws_iam_role" "authenticated" {
  name = "cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "appsync:GraphQL",
      "Resource": "arn:aws:appsync:eu-central-1:${var.account_id}:apis/${var.appsync_graphql_api_id}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-idp:*",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "unauthenticated" {
  name = "cognito_unauthenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
EOF

}
resource "aws_iam_role_policy" "unauthenticated" {
  name = "unauthenticated_policy"
  role = aws_iam_role.unauthenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  role_mapping {
    identity_provider         = "cognito-idp.us-central-1.amazonaws.com/${aws_cognito_user_pool.pool.id}:${aws_cognito_user_pool_client.client.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.authenticated.arn
      value      = "paid"
    }
  }
  role_mapping {
    identity_provider         = "cognito-idp.us-central-1.amazonaws.com/${aws_cognito_user_pool.pool.id}:${aws_cognito_user_pool_client.client.id}"
    ambiguous_role_resolution = "Deny"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.unauthenticated.arn
      value      = "paid"
    }
  }

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}

resource "aws_cognito_user_pool_ui_customization" "main" {
  css        = ".banner-customizable {background-color: white;} .submitButton-customizable {background-color: #36a5db;}"
  image_file = filebase64("nebim-logo.png")

  # Refer to the aws_cognito_user_pool_domain resource's
  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = aws_cognito_user_pool_domain.main.user_pool_id
}

resource "aws_cognito_user_group" "admin" {
  name         = "Admin"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Admin Group"
  role_arn     = aws_iam_role.authenticated.arn
}

resource "aws_cognito_user_group" "pos" {
  name         = "POS"
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = "Pos Group"
}