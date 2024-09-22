#!/bin/bash

PID=$$
bucket_name=$1
region=$2
table_name=$3

echo "WARNING: ALL RESOURCES, EVEN THE S3 BUCKET, WILL BE DELETED AFTER 10 MINUTES!"
echo "  TO PREVENT THAT, RUN:   kill -9 ${PID}"

sleep 600

echo "  Destroying..."

terraform destroy -auto-approve

# aws s3api delete-bucket-encryption --bucket $bucket_name --region $region
# aws s3api put-bucket-versioning \
#     --bucket $bucket_name \
#     --versioning-configuration Status=Suspended \
#     --region $region
aws s3api delete-objects --bucket ${bucket_name} --delete "$(aws s3api list-object-versions --bucket ${bucket_name} --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1
aws s3api delete-objects --bucket ${bucket_name} --delete "$(aws s3api list-object-versions --bucket ${bucket_name} --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1
aws s3 rm s3://$bucket_name --recursive > /dev/null 2>&1
aws s3 rb s3://$bucket_name --force > /dev/null 2>&1
echo "  S3 Bucket Deleted!"

aws dynamodb delete-table --table-name $table_name --region $region > /dev/null 2>&1
echo "  DynamoDB Table Deleted!"