# AWS Region
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Cognito User Pool Configuration
variable "cognito_user_pool_name" {
  type    = string
  default = "cognito-infra-prov"
}

# List of alias attributes for the Cognito User Pool
variable "alias_attributes" {
  type    = list(string)
  default = ["email"]
}

# Multi-Factor Authentication (MFA) Configuration
variable "mfa_configuration" {
  type    = string
  default = "OPTIONAL"
}

# SMS Authentication Message for MFA
variable "sms_authentication_message" {
  type    = string
  default = "Your verification code is {####}"
}

# Auto-verified attributes for users
variable "auto_verified_attributes" {
  type    = list(string)
  default = ["email"]
}

# Case sensitivity for user attribute values
variable "case_sensitive" {
  type    = bool
  default = false
}

# Priority for Cognito recovery mechanisms
variable "cognito_priority" {
  type    = number
  default = 1
}

# Priority for an additional Cognito recovery mechanism
variable "cognito_priority1" {
  type    = number
  default = 2
}

# Cognito attribute name for verified email
variable "cognito_name_email" {
  type    = string
  default = "verified_email"
}

# Cognito attribute name for verified phone number
variable "cognito_name_phone" {
  type    = string
  default = "verified_phone_number"
}

# Cognito User Pool Client Configuration

# Name of the Cognito User Pool Client
variable "cognito_user_pool_client" {
  type    = string
  default = "cognito-client-infra-prov"
}

# Callback URLs for the Cognito User Pool Client
variable "callback_urls" {
  type    = list(string)
  default = ["http://localhost:4200", "http://localhost:4200/login"]
}

# Logout URLs for the Cognito User Pool Client
variable "logout_urls" {
  type    = list(string)
  default = ["http://localhost:4200/logout"]
}

# Flag indicating whether the Cognito User Pool Client allows the OAuth flows
variable "allowed_oauth_flows_user_pool_client" {
  type    = bool
  default = true
}

# List of allowed OAuth flows for the Cognito User Pool Client
variable "allowed_oauth_flows" {
  type    = list(string)
  default = ["code"]
}

# Set of allowed OAuth scopes for the Cognito User Pool Client
variable "allowed_oauth_scopes" {
  type    = set(string)
  default = ["email", "openid", "phone_number"]
}

# List of supported identity providers for the Cognito User Pool Client
variable "supported_identity_providers" {
  type    = list(string)
  default = ["COGNITO"]
}

# Token validity duration for the Cognito User Pool Client
variable "access_token_validity" {
  type    = number
  default = 240
}

variable "refresh_token_validity" {
  type  = number
  default = 30
}

# ID token validity duration for the Cognito User Pool Client
variable "id_token_validity" {
  type    = number
  default = 240
}

# Cognito User Pool Domain Configuration

# Domain name for the Cognito User Pool
variable "cognito_user_pool_domain" {
  type    = string
  default = "infra-prov"
}


# Map of tags for all resources
variable "all_resource_tags" {
  type    = map(string)
  default = {
    environment = "dev"
    project     = "dac_project"
  }
}
