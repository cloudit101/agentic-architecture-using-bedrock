#!/bin/bash

# Set variables for CloudFormation stack name and S3 URLs
export STACK_NAME="Agentic-Architecture-Stack"
export DDL_URL="https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/ddl.sql"
export DATA_URL="https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/data.sql"
export QA_URL="https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/Pet_Store_QnA_data.csv"
export DB_KB_URL="https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/ddl.txt"

# Retrieve the RDS endpoint from the CloudFormation stack outputs
export DB_ENDPOINT=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='DBClusterEndpoint'].OutputValue" --output text)
export DB_PORT=5432
export DB_USER="postgres"
export DB_NAME="postgres"

# Retrieve the S3 bucket names for QnA and DB files from CloudFormation stack outputs
export QNA_BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='PetStoreQAKBBucket'].OutputValue" --output text)
export DB_BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='PetStoreDBKBBucket'].OutputValue" --output text)

# Prompt for the database password
read -sp "Enter database password for user $DB_USER: " DB_PASSWORD
echo

# Check if the endpoint was retrieved successfully
if [[ -z "$DB_ENDPOINT" ]]; then
  echo "Error: Unable to retrieve the database endpoint from CloudFormation stack outputs."
  exit 1
fi

# Confirm connection details
echo "Connecting to database at $DB_ENDPOINT:$DB_PORT with user $DB_USER..."

# Download ddl.sql file from S3 and execute it on the database
echo "Downloading DDL file and creating tables..."
curl -o ddl.sql "$DDL_URL"

# Drop the petstore database if it exists
echo "Dropping the petstore database if it exists..."
PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_ENDPOINT" -d "$DB_NAME" -c "DROP DATABASE IF EXISTS petstore;"

# Create the petstore database
echo "Creating the petstore database..."
PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_ENDPOINT" -d "$DB_NAME" -c "CREATE DATABASE petstore;"

# Add a comment to the petstore database
echo "Adding a comment to the petstore database..."
PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h "$DB_ENDPOINT" -d "$DB_NAME" -c "COMMENT ON DATABASE petstore IS 'This database is used for managing the Petstore application data, including pets, users, orders, and other related entities.';"

# Update the target database after it's been created
export DB_NAME="petstore"

PGPASSWORD=$DB_PASSWORD psql --host="$DB_ENDPOINT" --port="$DB_PORT" --username="$DB_USER" --dbname="$DB_NAME" -f ddl.sql
if [[ $? -ne 0 ]]; then
  echo "Error executing DDL script."
  exit 1
fi

# Download data.sql file from S3 and execute it on the database
echo "Downloading data file and inserting data..."
curl -o data.sql "$DATA_URL"

PGPASSWORD=$DB_PASSWORD psql --host="$DB_ENDPOINT" --port="$DB_PORT" --username="$DB_USER" --dbname="$DB_NAME" -f data.sql
if [[ $? -ne 0 ]]; then
  echo "Error executing data insert script."
  exit 1
fi

# Download and upload Pet_Store_QnA_data.csv
echo "Downloading Pet_Store_QnA_data.csv and uploading to QnA bucket..."
curl -o Pet_Store_QnA_data.csv "$QA_URL"
aws s3 cp Pet_Store_QnA_data.csv "s3://$QNA_BUCKET/Pet_Store_QnA_data.csv"
if [[ $? -ne 0 ]]; then
  echo "Error uploading Pet_Store_QnA_data.csv to QnA bucket."
  exit 1
fi

# Download and upload ddl.txt
echo "Downloading ddl.txt and uploading to DB bucket..."
curl -o ddl.txt "$DB_KB_URL"
aws s3 cp ddl.txt "s3://$DB_BUCKET/ddl.txt"
if [[ $? -ne 0 ]]; then
  echo "Error uploading ddl.txt to DB bucket."
  exit 1
fi
echo "Database setup and S3 file operations complete."