# EC2 Hosting Configuration

## Overview

The CV site runs on Amazon Linux 2023 with Apache HTTP Server on an Amazon EC2 instance.

## Instance Details

- **Instance name:** `cv-ec2-23l-3106`
- **Instance ID:** `i-05206484dfb765919`
- **Region:** `ap-southeast-2` (Asia Pacific — Sydney)
- **Instance type:** `t3.micro`
- **Operating system:** Amazon Linux 2023
- **Web server:** Apache HTTP Server (`httpd`)
- **Public IPv4 address:** `16.178.150.158`
- **IAM role:** `cv-ec2-role-23l-3106`

## Security Group

- **Security group name:** `cv-ec2-sg-23l-3106`
- **Inbound HTTP:** TCP port 80 from `0.0.0.0/0`
- **SSH:** No permanent public SSH access should be left open unless required for administration.
- **Outbound traffic:** Allowed as configured for the assignment.

## Website Synchronization

The instance assumes its IAM role to retrieve the website assets in the private S3 bucket `cv-23l-3106`, under the `site/` prefix.

The sync script copies website files into `/var/www/html/` and substitutes the EC2 instance identifier for `{{HOSTED_ON}}`. A systemd timer repeats the synchronization.

The synchronization log is stored at:

`/var/log/cv-sync.log`

## Verification

Before submitting, check the instance state, attached role, security-group rules, website response, and sync log against AWS.
