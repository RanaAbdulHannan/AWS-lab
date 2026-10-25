# Hosting a Personal CV on AWS

## Overview

This project demonstrates a personal CV deployment using Amazon S3, Amazon EC2, AWS Lambda, and AWS IAM. Website assets remain private in S3 and are delivered through the EC2 web server or the Lambda Function URL.

## Architecture

```text
                         Website visitors
                         /              \
                        v                v
                EC2 public IPv4     Lambda Function URL
                  Apache HTTP       Python Lambda handler
                        \                /
                         v              v
                       Private Amazon S3
                     Bucket: cv-23l-3106
                         Prefix: site/
```

## Request Flow

For EC2, the browser sends an HTTP request to the instance's public IPv4 address. Apache serves the local website files, which are synchronized from the private S3 bucket using the EC2 IAM role.

For Lambda, the browser sends a request to the public Function URL. The Python handler reads the requested file from S3 using the Lambda execution role and returns the appropriate content type.

## AWS Resources

| Resource | Name |
|---|---|
| S3 bucket | `cv-23l-3106` |
| EC2 instance | `cv-ec2-23l-3106` |
| EC2 IAM role | `cv-ec2-role-23l-3106` |
| EC2 security group | `cv-ec2-sg-23l-3106` |
| Lambda function | `cv-func-23l-3106` |
| Lambda IAM role | `cv-lambda-role-23l-3106` |
| AWS Region | `ap-southeast-2` (Sydney) |

## Security

- Keep S3 Block Public Access enabled and do not grant public-read access through a bucket policy or ACL.
- Use IAM roles for EC2 and Lambda instead of storing long-lived access keys.
- Limit the EC2 and Lambda roles to the required `site/` objects; restrict bucket listing to that prefix.
- Allow the Lambda role to write execution logs to CloudWatch.

## S3 Direct Access

Opening the direct S3 URL for `index.html` should return `AccessDenied`: the bucket is private and public access is blocked. Visitors should use the EC2 or Lambda website endpoint.

## Synchronization Log

The EC2 synchronization log is at `/var/log/cv-sync.log`. Include its last 10 lines in the submission as required by the assignment.

## Assignment Questions

### 1. Why use IAM roles instead of access keys? What could go wrong if keys were placed in user data?

IAM roles deliver temporary credentials without embedding permanent keys in code or on the instance. Keys placed in user data can leak through instance metadata, logs, configuration access, or accidental sharing, giving an unintended party access until the keys are revoked.

### 2. What happens when the direct S3 URL for `index.html` is opened, and which setting causes this?

The request should return `AccessDenied`. The bucket is private, S3 Block Public Access prevents public access settings from taking effect, and no public-read policy or ACL grants access.

### 3. Why can anyone call the Lambda Function URL, and why is that acceptable for the function but not for the bucket?

The Function URL is configured with authentication type `NONE`, so anyone can invoke it without AWS IAM credentials. That is suitable for a public CV endpoint only while the handler serves intended website files. Keep S3 private so visitors cannot directly list or fetch other bucket objects.

### 4. How do costs compare when there is no traffic, and what happens if traffic increases 100 times?

With no requests, a running EC2 instance can still incur compute charges; Lambda is generally billed for invocations and execution time, subject to applicable free allowances and other service charges. At 100 times the traffic, Lambda usage charges can increase with invocations and duration, while EC2 costs depend on capacity and any scaling or extra infrastructure. The actual comparison depends on region, workload, free-tier eligibility, and related services.

### 5. If the EC2 instance is deleted, what is lost and what remains?

The EC2 website endpoint becomes unavailable, and instance-local files, configuration, and logs may be lost unless backed up. Separately managed resources—such as the S3 bucket and its files, Lambda function and URL, and IAM roles—remain unless they are deleted separately.

## Evidence

See `evidence.txt` for the recorded AWS checks. Recollect and verify the output against the current AWS resources before submission.

## EC2
http://16.178.150.158/
<img width="1860" height="851" alt="image" src="https://github.com/user-attachments/assets/933683c5-191c-45fa-804f-559e5eee7163" />

## Lambda function
https://a4edahpervknw5t34nf6nfpqdu0dcmuc.lambda-url.ap-southeast-2.on.aws/
<img width="1860" height="851" alt="image" src="https://github.com/user-attachments/assets/aa75adee-f22d-4480-8db5-2ed390e2ed4b" />




