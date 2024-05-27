resource "aws_s3_bucket" "s3_bucket" {
    for_each = toset(var.s3_bucket_name)
    bucket        = each.key
    tags          = var.tags
    force_destroy = var.force_destroy
    
}
resource "aws_s3_bucket_cors_configuration" "projects_bucket_cors" {
  for_each = aws_s3_bucket.s3_bucket
  bucket= each.key
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 0
  }
}


resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  for_each = aws_s3_bucket.s3_bucket
  bucket= each.key
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  for_each = aws_s3_bucket.s3_bucket
  bucket= each.key
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block_public_access" {
  for_each = aws_s3_bucket.s3_bucket
  bucket= each.key
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}