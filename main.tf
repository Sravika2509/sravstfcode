# Create a Cognito User Pool
resource "aws_cognito_user_pool" "cognito-user-pool-infra-prov" {
  name                       = var.cognito_user_pool_name
  alias_attributes           = var.alias_attributes
  #mfa_configuration          = var.mfa_configuration
  sms_authentication_message = var.sms_authentication_message
  
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    temporary_password_validity_days = 365
  }
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

  verification_message_template {
    email_message = "Your verification code is {####}"
    email_subject = "Your verification code"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  tags = var.all_resource_tags
}

# Create a Cognito User Pool Client
resource "aws_cognito_user_pool_client" "cognito-client-infra-prov" {
  name                                 = var.cognito_user_pool_client
  user_pool_id                         = aws_cognito_user_pool.cognito-user-pool-infra-prov.id
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  supported_identity_providers         = var.supported_identity_providers
  access_token_validity                = var.access_token_validity
  id_token_validity                    = var.id_token_validity
  refresh_token_validity               = var.refresh_token_validity

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  enable_token_revocation = true
  prevent_user_existence_errors = "ENABLED"
}

# Create a Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "cognito-user-pool-domain-infra-prov" {
  domain       = var.cognito_user_pool_domain
  user_pool_id = aws_cognito_user_pool.cognito-user-pool-infra-prov.id
}
