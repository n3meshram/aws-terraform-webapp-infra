#!/bin/bash

echo "Content-type: text/html"
echo ""

INPUT_PASSWORD=$(printf "%s" "$QUERY_STRING" | sed 's/^password=//')

APP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "/${environment}/app/password" \
  --query SecretString \
  --output text | jq -r '.password')

INPUT_PASSWORD=$(echo "$INPUT_PASSWORD" | tr -d '\r\n')
APP_PASSWORD=$(echo "$APP_PASSWORD" | tr -d '\r\n')

if [ -n "$INPUT_PASSWORD" ] && [ "$INPUT_PASSWORD" = "$APP_PASSWORD" ]; then
    echo "<h1>Access Granted</h1>"
else
    echo "<h1>Access Denied</h1>"
fi