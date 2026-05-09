#!/bin/bash

set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./setup-backend.sh dev|stage|prod"
  exit 1
fi

cd bootstrap

terraform init -input=false
terraform apply -auto-approve

BUCKET=$(terraform output -raw bucket_name)
TABLE=$(terraform output -raw dynamodb_table)

cd ../environments/$ENV

cat <<EOF > backend.hcl
bucket         = "$BUCKET"
key            = "$ENV/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "$TABLE"
EOF

terraform init -backend-config=backend.hcl

echo "✅ Backend setup complete for $ENV"