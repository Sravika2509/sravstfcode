# Cognito User Pool Configuration
cognito_user_pool_name      = "coginto-infra-prov"
alias_attributes            = ["email"]
mfa_configuration           = "OPTIONAL"
sms_authentication_message  = "Your verification code is {####}"
auto_verified_attributes    = ["email"]
case_sensitive              = false

# Cognito User Attributes
name_cognito                = "email"
cognito_required            = true
cognito-minlength           = 1
cognito-maxlength           = 2048
cognito-priority            = 1
cognito-priority1           = 2
cognito-name-email          = "verified_email"

# Cognito User Pool Client Configuration
cognito_user_pool_client    = "cognito-client-infra-prov"
callback_urls               = ["http://localhost:4200", "http://localhost:4200/login"]
logout_urls                 = ["http://localhost:4200/logout"]
allowed_oauth_flows_user_pool_client = true
allowed_oauth_flows         = ["code"]
allowed_oauth_scopes        = ["email", "openid"]
supported_identity_providers= ["COGNITO"]
access_token_validity       = 240
id_token_validity           = 240

# Cognito User Pool Domain Configuration
cognito_user_pool_domain    = "infra-prov"

# AWS Region
region                      = "us-east-1"

# Additional Cognito User Attribute Configuration
name_cognito_phone          = "phone_number"
phone_number_attribute_data_type = "String"
phone_number_mutable        = true
phone_number_required       = true
phone_number_minlength      = 1
phone_number_maxlength      = 15

# Map of tags for all resources
all_resource_tags = {
  environment = "dev"
  project     = "dac_project"
}
