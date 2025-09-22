#!/bin/bash
# Firebase Cloud Messaging Topic Test Script

set -e

# Configuration - UPDATE THESE VALUES
PROJECT_ID="furdle"  # Your Firebase project ID
TOPIC="daily_challenge"       # Your topic name

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Firebase Topic Notification Test${NC}"
echo "=================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Error: gcloud CLI is not installed${NC}"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get access token
echo -e "${YELLOW}📋 Getting access token...${NC}"
ACCESS_TOKEN=$(gcloud auth print-access-token 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ Error: Could not get access token${NC}"
    echo "Please run: gcloud auth login"
    exit 1
fi

# Validate project ID
if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo -e "${RED}❌ Error: Please update PROJECT_ID in the script${NC}"
    echo "Edit this file and replace 'your-project-id' with your actual Firebase project ID"
    exit 1
fi

echo -e "${GREEN}✓ Using Firebase project: $PROJECT_ID${NC}"

# Generate test data
CHALLENGE_NUM=$((RANDOM % 1000 + 1))
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

echo -e "${BLUE}📤 Sending test notification...${NC}"
echo "Project: $PROJECT_ID"
echo "Topic: $TOPIC"
echo "Challenge: #$CHALLENGE_NUM"
echo "Timestamp: $TIMESTAMP"
echo ""

# Send notification
RESPONSE=$(curl -s -X POST \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "'${TOPIC}'",
      "notification": {
        "title": "🧩 Test Furdle Challenge!",
        "body": "Challenge #'${CHALLENGE_NUM}' is now available. Can you solve today'\''s word?"
      },
      "data": {
        "action": "new_challenge",
        "challengeNumber": "'${CHALLENGE_NUM}'",
        "timestamp": "'${TIMESTAMP}'",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "android": {
        "notification": {
          "channel_id": "furdle_notifications",
          "priority": "high",
          "default_sound": true,
          "default_vibrate_timings": true,
          "icon": "ic_notification",
          "color": "#6200EE"
        }
      },
      "apns": {
        "payload": {
          "aps": {
            "alert": {
              "title": "🧩 Test Furdle Challenge!",
              "body": "Challenge #'${CHALLENGE_NUM}' is now available. Can you solve today'\''s word?"
            },
            "sound": "default",
            "badge": 1
          }
        }
      }
    }
  }' 2>/dev/null)

echo -e "${BLUE}📨 Response:${NC}"
echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""

# Check if successful
if echo "$RESPONSE" | grep -q '"name"'; then
    MESSAGE_ID=$(echo "$RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | cut -d'/' -f4)
    echo -e "${GREEN}✅ Notification sent successfully!${NC}"
    echo -e "${GREEN}📧 Message ID: ${MESSAGE_ID}${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo "• Check your app to see if the notification arrived"
    echo "• Notifications may not show if the app is in foreground"
    echo "• Check Firebase Console > Cloud Messaging for delivery stats"
    echo "• Make sure your app is subscribed to the '$TOPIC' topic"
elif echo "$RESPONSE" | grep -q "error"; then
    echo -e "${RED}❌ Failed to send notification${NC}"
    
    # Parse common errors
    if echo "$RESPONSE" | grep -q "UNAUTHENTICATED"; then
        echo -e "${RED}🔐 Authentication error. Try: gcloud auth login${NC}"
    elif echo "$RESPONSE" | grep -q "INVALID_ARGUMENT"; then
        echo -e "${RED}📝 Invalid argument. Check topic name and payload format${NC}"
    elif echo "$RESPONSE" | grep -q "NOT_FOUND"; then
        echo -e "${RED}🔍 Project not found. Check your PROJECT_ID${NC}"
    fi
else
    echo -e "${RED}❌ Unexpected response${NC}"
fi

echo ""
echo -e "${BLUE}🔗 Useful Links:${NC}"
echo "• Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID/messaging"
echo "• FCM Documentation: https://firebase.google.com/docs/cloud-messaging"
