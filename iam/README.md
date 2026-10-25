# IAM Role Configuration

## Overview

EC2 and Lambda use AWS IAM roles for temporary, managed access to the private S3 bucket. Long-term AWS access keys are not stored in the application or on the instance.

## EC2 Role

- **Role name:** `cv-ec2-role-23l-3106`
- **Trusted service:** EC2
- **Inline policy:** `cv-ec2-s3-read`

Permissions:
- `s3:GetObject` on `arn:aws:s3:::cv-23l-3106/site/*`
- `s3:ListBucket` on `arn:aws:s3:::cv-23l-3106`, restricted to the `site/` prefix.

## Lambda Role

- **Role name:** `cv-lambda-role-23l-3106`
- **Trusted service:** Lambda
- **Managed policy:** `AWSLambdaBasicExecutionRole`
- **Inline policy:** `cv-lambda-s3-read`

Permission:
- `s3:GetObject` on `arn:aws:s3:::cv-23l-3106/site/*`

## Security Notes

- Keep the S3 bucket private and leave Block Public Access enabled.
- Use IAM roles for S3 access instead of embedding credentials.
- Grant only the object and service permissions needed by each application component.

## Verification

Before submission, compare the role names, trust relationships, policies, and resource ARNs with the current AWS configuration.
