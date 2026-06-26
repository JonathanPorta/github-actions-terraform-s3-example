## ========================================================================== ##
#  Terraform State S3 Bucket                                                   #
## ========================================================================== ##

# Provides an S3 bucket for storing Terraform state files
resource "aws_s3_bucket" "this" {
  bucket = "jonathanporta-github-actions-terraform-s3-example"

  tags = {
    Name = "jonathanporta-github-actions-terraform-s3-example"
  }
}

# Enforce object ownership so the bucket ACL can be applied predictably
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Keep the bucket private
resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

# Retain previous versions of the Terraform state file
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Provides additional layers of security to block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

terraform {
  backend "s3" {
    bucket = "jonathanporta-github-actions-terraform-s3-example"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
