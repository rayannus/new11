provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "s3-bucket-terraform-demo"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id = "DeleteAfter30Days"
    enabled = true

    transition {
      days = 10
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 30
    }
  }

  logging {
    target_bucket = self.bucket
    target_prefix = "logs/"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DenyPublicAccess"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "arn:aws:s3:::s3-bucket-terraform-demo/*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      },
      {
        Sid = "AllowLoggingAccess"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::s3-bucket-terraform-demo/logs/*"
        ]
      }
    ]
  })
}