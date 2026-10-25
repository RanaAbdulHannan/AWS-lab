
import os
import json
import time
import base64
import logging
import boto3
from urllib.parse import unquote

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]
PREFIX = os.environ.get("PREFIX", "site/")

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    start = time.time()
    path = unquote(event.get("rawPath", "/"))
    if path == "":
        path = "/"

    status = 200
    content_type = "text/html; charset=utf-8"
    headers = {
        "Content-Type": content_type,
        "Cache-Control": "max-age=60",
    }
    body = ""
    is_base64 = False

    try:
        if path in ("/", "/index.html"):
            key = PREFIX + "index.html"
            obj = s3.get_object(Bucket=BUCKET, Key=key)
            body = obj["Body"].read().decode("utf-8")
            body = body.replace(
                "{{HOSTED_ON}}",
                "Lambda - " + context.function_name
            )

        elif path == "/style.css":
            obj = s3.get_object(
                Bucket=BUCKET, Key=PREFIX + "style.css"
            )
            body = obj["Body"].read().decode("utf-8")
            headers["Content-Type"] = "text/css; charset=utf-8"

        elif path == "/cv.pdf":
            obj = s3.get_object(
                Bucket=BUCKET, Key=PREFIX + "cv.pdf"
            )
            body = base64.b64encode(obj["Body"].read()).decode("ascii")
            headers["Content-Type"] = "application/pdf"
            is_base64 = True

        else:
            status = 404
            body = "<html><body><h1>404 Not Found</h1></body></html>"

    except Exception:
        logger.exception("Unable to serve the requested website resource")
        status = 500
        body = "<html><body><h1>Internal Server Error</h1></body></html>"

    # Keep a compact request record for CloudWatch troubleshooting.
    logger.info(json.dumps({
        "fn": context.function_name,
        "path": path,
        "status": status,
        "ms": round((time.time() - start) * 1000, 2),
    }))

    return {
        "statusCode": status,
        "headers": headers,
        "body": body,
        "isBase64Encoded": is_base64,
    }
