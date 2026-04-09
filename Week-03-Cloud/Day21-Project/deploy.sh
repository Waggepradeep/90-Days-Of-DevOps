#!/bin/bash

BUCKET="devops-day21-pradeep-001"
REGION="ap-south-1"

echo "🚀 Deploying to S3..."

aws s3 cp index.html s3://$BUCKET/

echo "✅ Deployment complete!"
echo "🌍 Live at: http://$BUCKET.s3-website.$REGION.amazonaws.com"
