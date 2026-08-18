import io
import os
import urllib.parse

import boto3
from PIL import Image, ImageOps

s3 = boto3.client("s3")

THUMBNAIL_PREFIX = "thumbnails/"


def lambda_handler(event, context):
    processed = []

    for record in event.get("Records", []):
        if record.get("eventSource") != "aws:s3":
            continue

        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        if not key.startswith("originals/"):
            continue

        response = s3.get_object(Bucket=bucket, Key=key)
        image_bytes = response["Body"].read()

        with Image.open(io.BytesIO(image_bytes)) as image:
            image = ImageOps.exif_transpose(image)
            image.thumbnail((400, 400))

            extension = os.path.splitext(key)[1].lower()
            output = io.BytesIO()

            if extension in {".jpg", ".jpeg"}:
                if image.mode not in {"RGB", "L"}:
                    image = image.convert("RGB")
                image.save(output, format="JPEG", quality=85, optimize=True)
                content_type = "image/jpeg"
            elif extension == ".webp":
                image.save(output, format="WEBP", quality=85)
                content_type = "image/webp"
            else:
                if image.mode not in {"RGB", "RGBA", "L"}:
                    image = image.convert("RGBA")
                image.save(output, format="PNG", optimize=True)
                content_type = "image/png"

            output.seek(0)

            thumbnail_key = THUMBNAIL_PREFIX + key[len("originals/"):]

            s3.put_object(
                Bucket=bucket,
                Key=thumbnail_key,
                Body=output,
                ContentType=content_type
            )

            processed.append(thumbnail_key)

    return {
        "processed": processed,
        "count": len(processed)
    }
