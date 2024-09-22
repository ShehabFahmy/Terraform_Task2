#!/bin/bash

bucket_name="devops-tf-task2-bucket"
region="us-east-1"
table_name="state-lock"

# Create the S3 bucket for a remote state backend
# The `--create-bucket-configuration` is required when creating an S3 bucket in a region other than the us-east-1 (N. Virginia) region.
aws s3api create-bucket --bucket $bucket_name --region $region #--create-bucket-configuration LocationConstraint=us-east-1
aws s3api put-bucket-versioning \
    --bucket $bucket_name \
    --versioning-configuration Status=Enabled \
    --region $region
aws s3api put-bucket-encryption \
    --bucket $bucket_name \
    --server-side-encryption-configuration '{
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "aws:kms"
          }
        }
      ]
    }' \
    --region $region

# Create the DynamoDB for the state lock
aws dynamodb create-table \
    --table-name $table_name \
    --billing-mode PAY_PER_REQUEST \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --region $region > /dev/null 2>&1   # Suppress the JSON output to continue the script

terraform workspace new dev

terraform init

echo -e "\033[H\033[2J"   # similar to ctrl + l without clearing the terminal

terraform apply

# Terminate the temporary EC2 instance and its VPC
echo "  Terminating Temporary EC2 Instance..."
sleep 2
terraform apply -var="create-instance-for-ami=false" -auto-approve

# Run the destroy script
./End.sh $bucket_name $region $table_name &
