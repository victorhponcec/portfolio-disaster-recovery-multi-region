provider "aws" {
  alias  = "primary"
  region = "us-east-1"  # primary bucket region
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-1"  # secondary bucket region
}

provider "aws" {
  alias  = "s3control"
  region = "us-west-2"  # MRAP region
}

resource "random_string" "primary" {
  length  = 8
  upper   = false
  special = false
}

resource "random_string" "secondary" {
  length  = 8
  upper   = false
  special = false
}

# Primary bucket

resource "aws_s3_bucket" "primary" {
  provider        = aws.primary
  bucket          = "app-primary-${random_string.primary.result}"
  force_destroy   = true
}

resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Secondary bucket

resource "aws_s3_bucket" "secondary" {
  provider      = aws.secondary
  bucket        = "app-secondary-${random_string.secondary.result}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id

  versioning_configuration {
    status = "Enabled"
  }
}

# replication Role


resource "aws_iam_role" "replication_role" {
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

resource "aws_iam_role_policy" "replication_policy" {
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.primary.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.primary.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ]
        Resource = "${aws_s3_bucket.secondary.arn}/*"
      }
    ]
  })
}

# S3 replication

resource "aws_s3_bucket_replication_configuration" "primary_to_secondary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  role     = aws_iam_role.replication_role.arn

  rule {
    id     = "primary-to-secondary"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.secondary
  ]
}

# multi-region Access Point MRAP

resource "aws_s3control_multi_region_access_point" "mrap" {
  provider = aws.s3control

  details {
    name = "app-mrap"

    region {
      bucket = aws_s3_bucket.primary.id
    }

    region {
      bucket = aws_s3_bucket.secondary.id
    }

    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }

  depends_on = [
    aws_s3_bucket_replication_configuration.primary_to_secondary
  ]
}