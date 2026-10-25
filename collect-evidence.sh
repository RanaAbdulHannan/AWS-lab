#!/usr/bin/env bash
set -u

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 BUCKET EC2_ADDRESS LAMBDA_URL"
  exit 1
fi

BUCKET="$1"
EC2_ADDRESS="$2"
LAMBDA_URL="$3"
OUT="evidence.txt"
REGION="ap-southeast-2"
EC2_NAME="cv-ec2-23l-3106"
EC2_ROLE="cv-ec2-role-23l-3106"
LAMBDA_NAME="cv-func-23l-3106"
LAMBDA_ROLE="cv-lambda-role-23l-3106"
SG_NAME="cv-ec2-sg-23l-3106"

command -v aws >/dev/null 2>&1 || {
  echo "ERROR: Install the AWS CLI before collecting evidence."
  exit 1
}

command -v curl >/dev/null 2>&1 || {
  echo "ERROR: Install curl before checking the website endpoints."
  exit 1
}

run_section() {
  title="$1"
  shift
  {
    echo
    echo "=================================================="
    echo "$title"
    echo "=================================================="
    "$@" 2>&1 || echo "NOTE: Check AWS permissions, resource names, and configuration, then retry this check."
  } >> "$OUT"
}

{
  echo "CV WEBSITE - AWS VERIFICATION RECORD"
  echo "Collected at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Region: $REGION"
  echo "Bucket: $BUCKET"
  echo "EC2 address: $EC2_ADDRESS"
  echo "Lambda URL: $LAMBDA_URL"
} > "$OUT"

run_section "1. AWS CALLER IDENTITY" aws sts get-caller-identity

run_section "2. S3 PUBLIC ACCESS BLOCK" aws s3api get-public-access-block --bucket "$BUCKET" --region "$REGION"

run_section "3. S3 VERSIONING" aws s3api get-bucket-versioning --bucket "$BUCKET" --region "$REGION"

run_section "4. S3 WEBSITE OBJECTS" aws s3 ls "s3://$BUCKET/site/" --region "$REGION"

run_section "5. EC2 IAM ROLE POLICY" aws iam get-role-policy --role-name "$EC2_ROLE" --policy-name cv-ec2-s3-read

run_section "6. LAMBDA IAM ROLE POLICY" aws iam get-role-policy --role-name "$LAMBDA_ROLE" --policy-name cv-lambda-s3-read

run_section "7. EC2 SECURITY GROUP" bash -c 'aws ec2 describe-security-groups --region "$1" --filters "Name=group-name,Values=$2" --output json' _ "$REGION" "$SG_NAME"

run_section "8. EC2 INSTANCE DETAILS" bash -c 'aws ec2 describe-instances --region "$1" --filters "Name=tag:Name,Values=$2" --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType,PublicIP:PublicIpAddress,IAMProfile:IamInstanceProfile.Arn}" --output json' _ "$REGION" "$EC2_NAME"

run_section "9. WEBSITE ENDPOINT CHECKS" bash -c '
for url in "$1" "$2" "$3" "$4"; do
  echo
  echo "URL: $url"
  curl -sS -L -o /dev/null -w "HTTP status: %{http_code}\nContent type: %{content_type}\n" --max-time 20 "$url" || echo "NOTE: Endpoint request failed."
done
' _ "http://$EC2_ADDRESS/" "http://$EC2_ADDRESS/style.css" "http://$EC2_ADDRESS/cv.pdf" "${LAMBDA_URL%/}/"

run_section "10. LAMBDA CLOUDWATCH LOGS" aws logs tail "/aws/lambda/$LAMBDA_NAME" --since 1d --region "$REGION"

run_section "11. LAMBDA LOG RETENTION" aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/$LAMBDA_NAME" --region "$REGION" --query 'logGroups[].{LogGroup:logGroupName,RetentionInDays:retentionInDays}' --output json

echo
echo "Verification record written to $OUT"
echo "Inspect $OUT and resolve any failed checks before submission."
