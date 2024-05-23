# Create a Cognito User Pool
resource "aws_cognito_user_pool" "cognito-user-pool-infra-prov" {
  name                       = var.cognito_user_pool_name
  alias_attributes           = var.alias_attributes
  mfa_configuration          = var.mfa_configuration
  sms_authentication_message = var.sms_authentication_message
  auto_verified_attributes   = var.auto_verified_attributes

  # Configure software token MFA
  software_token_mfa_configuration {
    enabled = false
  }

  # Define user pool schema for standard attributes
  dynamic "schema" {
    for_each = split(",", var.name_cognito)
    content {
      name                = schema.value
      attribute_data_type = var.attribute_data_type
      mutable             = var.mutable
      required            = var.cognito_required

      # Configure string attribute constraints
      string_attribute_constraints {
        min_length = var.cognito-minlength
        max_length = var.cognito-maxlength
      }
    }
  }

  # Define user pool schema for phone number attributes
  dynamic "schema" {
    for_each = split(",", var.name_cognito_phone)
    content {
      name                = schema.value
      attribute_data_type = var.phone_number_attribute_data_type
      mutable             = var.phone_number_mutable
      required            = var.phone_number_required

      # Configure string attribute constraints for phone numbers
      string_attribute_constraints {
        min_length = var.phone_number_minlength
        max_length = var.phone_number_maxlength
      }
    }
  }

  # Configure account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = var.cognito-name-email
      priority = var.cognito-priority
    }
    recovery_mechanism {
      name     = var.cognito-name-phone
      priority = var.cognito-priority1
    }
  }

  # Configure username settings
  username_configuration {
    case_sensitive = var.case_sensitive
  }

  # Add tags to the Cognito User Pool
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

  # Token validity settings
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Configure explicit auth flows
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

# Create a Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "coginito-user-pool-domain-infra-prov" {
  domain       = var.cognito_user_pool_domain
  user_pool_id = aws_cognito_user_pool.cognito-user-pool-infra-prov.id
}
