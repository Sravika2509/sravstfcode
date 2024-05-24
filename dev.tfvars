# Cognito User Pool Configuration
cognito_user_pool_name      = "cognito-infra-prov"
alias_attributes            = ["email"]
mfa_configuration           = "OFF"
sms_authentication_message  = "Your verification code is {####}"

# Cognito User Pool Client Configuration
cognito_user_pool_client    = "cognito-client-infra-prov"
callback_urls               = ["https://localhost:3000"]
logout_urls                 = ["https://localhost:3000/logout"]
allowed_oauth_flows_user_pool_client = true
allowed_oauth_flows         = ["code", "implicit"]
allowed_oauth_scopes        = ["aws.cognito.signin.user.admin", "email", "openid", "phone", "profile"]
supported_identity_providers= ["COGNITO"]
access_token_validity       = 1440  # 1 day in minutes
id_token_validity           = 1440  # 1 day in minutes
refresh_token_validity      = 30  # 30 days


# Cognito User Pool Domain Configuration
cognito_user_pool_domain    = "infra-prov"

# Tags
all_resource_tags = {
  environment = "dev"
  project     = "dac_project"
}
