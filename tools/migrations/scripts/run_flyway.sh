#!/usr/bin/env bash

set -euo pipefail

# Check argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <postgres|auth>"
  exit 1
fi

TARGET_DB=$1

# Get script directory and move to migrations directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIGRATIONS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$MIGRATIONS_DIR"

# Load .env file
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
else
  echo "Error: .env file not found in $MIGRATIONS_DIR"
  echo "Please copy .env.sample to .env and configure it"
  exit 1
fi

# Flyway Configuration
FLYWAY_SCHEMAS="public"
FLYWAY_CONNECT_RETRIES="60"
FLYWAY_LOCATIONS="filesystem:/flyway/sql/$TARGET_DB"

echo "Running Flyway migration for $TARGET_DB database..."

# Run Flyway ECS Task
TASK_ARN=$(aws ecs run-task \
  --cluster "$ECS_CLUSTER" \
  --task-definition "$FLYWAY_TASK_FAMILY" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2],securityGroups=[$ECS_SECURITY_GROUP],assignPublicIp=DISABLED}" \
  --overrides "{
    \"containerOverrides\": [{
      \"name\": \"$FLYWAY_CONTAINER_NAME\",
      \"environment\": [
        {\"name\": \"FLYWAY_URL\", \"value\": \"jdbc:postgresql://$DB_ENDPOINT:5432/$TARGET_DB\"},
        {\"name\": \"FLYWAY_SCHEMAS\", \"value\": \"$FLYWAY_SCHEMAS\"},
        {\"name\": \"FLYWAY_USER\", \"value\": \"$DB_USERNAME\"},
        {\"name\": \"FLYWAY_PASSWORD\", \"value\": \"$DB_PASSWORD\"},
        {\"name\": \"FLYWAY_CONNECT_RETRIES\", \"value\": \"$FLYWAY_CONNECT_RETRIES\"},
        {\"name\": \"FLYWAY_LOCATIONS\", \"value\": \"$FLYWAY_LOCATIONS\"}
      ]
    }]
  }" \
  --query 'tasks[0].taskArn' \
  --output text)

echo "Task: $TASK_ARN"

# Wait for Task to Complete
aws ecs wait tasks-stopped --cluster "$ECS_CLUSTER" --tasks "$TASK_ARN"

EXIT_CODE=$(aws ecs describe-tasks \
  --cluster "$ECS_CLUSTER" \
  --tasks "$TASK_ARN" \
  --query 'tasks[0].containers[0].exitCode' \
  --output text)

if [ "$EXIT_CODE" = "0" ]; then
  echo "Migration completed successfully for $TARGET_DB database"
else
  echo "Migration failed with exit code: $EXIT_CODE"
  exit 1
fi
