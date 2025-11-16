resource "random_string" "app_primary" {
  length  = 10
  upper   = false
  special = false
}
resource "random_string" "app_secondary" {
  length  = 10
  upper   = false
  special = false
}

resource "aws_s3_bucket" "app_primary" {
  bucket        = "vpc-flow-logs-${random_string.app_primary.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "app_secondary" {
  bucket        = "vpc-flow-logs-${random_string.app_secondary.result}"
  force_destroy = true
}

resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.app_primary.arn
      },
      {
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.app_primary.arn}/*"
      },
      {
        Action   = ["s3:ReplicateObject", "s3:ReplicateDelete"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.app_secondary.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.west1
  bucket   = aws_s3_bucket.app_primary.id
  role     = aws_iam_role.replication.arn

  rule {
    id     = "primary-to-secondary"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.app_secondary.arn
      storage_class = "STANDARD"
    }
  }
}

#Multi-Region Access Point
resource "aws_s3control_multi_region_access_point" "mrap" {
  provider = aws.west1

  details {
    name = "APP-MRAP"
    region {
      bucket = aws_s3_bucket.app_primary.id
    }
    region {
      bucket = aws_s3_bucket.app_secondary.id
    }

    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }

  depends_on = [
    aws_s3_bucket.app_primary,
    aws_s3_bucket.app_secondary
  ]
}
