variable "s3_bucket_name" {
  type = string
  default = "infraprovassvc12345"
  description = "S3 Bucket Name"
}

variable "force_destroy" {
  type = bool
  description = "Force destroy the bucket"
  default = true
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to the S3 bucket name"
}

variable "random_suffix_length" {
  description = "Length of the random suffix for the bucket name"
  default     = 8
}