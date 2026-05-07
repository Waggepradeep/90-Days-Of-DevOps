#!/bin/bash
BUCKET="devops-day21-pradeep-001"
REGION="ap-south-1"
echo "🚀 Deploying..."
aws s3 sync . s3://$BUCKET/ --exclude ".git/*" --exclude "deploy.sh"
echo "✅ Done!"
echo "🌍 http://$BUCKET.s3-website.$REGION.amazonaws.com"
