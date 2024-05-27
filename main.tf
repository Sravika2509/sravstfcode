resource "random_id" "bucket_suffix" {
  byte_length = var.random_suffix_length
}

resource "aws_s3_bucket" "s3_bucket" {
    bucket        = "${var.s3_bucket_name}-${random_id.bucket_suffix.hex}"
    tags          = var.tags
    force_destroy = var.force_destroy
    
}
resource "aws_s3_bucket_cors_configuration" "projects_bucket_cors" {
  bucket = aws_s3_bucket.s3_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 0
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket        = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket        = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block_public_access" {
  bucket        = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}