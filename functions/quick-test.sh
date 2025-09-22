#!/bin/bash
# Quick FCM Topic Test - One-liner version

# Your Firebase project ID (from .firebaserc)
PROJECT_ID="furdle"
TOPIC="daily_challenge"

# Get token and send notification in one command
echo "🚀 Quick FCM Test..."
ACCESS_TOKEN=$(gcloud auth print-access-token) && \
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "'${TOPIC}'",
      "notification": {
        "title": "🧩 Quick Test!",
        "body": "Testing FCM from curl - '$(date)'"
      },
      "data": {
        "action": "test",
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'"
      }
    }
  }' | jq .

echo ""
echo "✅ Check your Furdle app for the notification!"
