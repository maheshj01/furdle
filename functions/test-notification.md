# Testing Firebase Topic Notifications with curl

## Prerequisites

1. **Service Account Key**: Download your Firebase service account JSON key
2. **Access Token**: Generate an OAuth 2.0 access token
3. **Project ID**: Your Firebase project ID

## Step 1: Get Access Token

### Option A: Using Google Cloud CLI (Recommended)
```bash
# Install gcloud CLI if not installed
# https://cloud.google.com/sdk/docs/install

# Authenticate
gcloud auth login

# Get access token
ACCESS_TOKEN=$(gcloud auth print-access-token)
echo $ACCESS_TOKEN
```

### Option B: Using Service Account Key
```bash
# Install google-auth-oauthlib if not installed
pip install google-auth google-auth-oauthlib google-auth-httplib2

# Create a Python script to get token
cat > get_token.py << 'EOF'
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# Path to your service account key file
SERVICE_ACCOUNT_FILE = 'path/to/your/service-account-key.json'
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES)

credentials.refresh(Request())
print(credentials.token)
EOF

python get_token.py
```

## Step 2: Test Topic Notification

### Basic Topic Notification
```bash
# Set variables
PROJECT_ID="your-project-id"
ACCESS_TOKEN="your-access-token"
TOPIC="daily_challenge"  # or "furdle_daily_challenges"

# Send notification to topic
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "'${TOPIC}'",
      "notification": {
        "title": "🧩 Test Furdle Challenge!",
        "body": "This is a test notification from curl"
      },
      "data": {
        "action": "test_challenge",
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'"
      }
    }
  }'
```

### Advanced Topic Notification (Matching Your Function)
```bash
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "'${TOPIC}'",
      "notification": {
        "title": "🧩 New Furdle Challenge!",
        "body": "Challenge #999 is now available. Can you solve today'\''s word?"
      },
      "data": {
        "action": "new_challenge",
        "challengeNumber": "999",
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
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
              "title": "🧩 New Furdle Challenge!",
              "body": "Challenge #999 is now available. Can you solve today'\''s word?"
            },
            "sound": "default",
            "badge": 1
          }
        }
      }
    }
  }'
```

## Step 3: Create a Test Script

Create a reusable test script:

```bash
#!/bin/bash
# save as test-fcm.sh

set -e

# Configuration
PROJECT_ID="your-project-id"
TOPIC="daily_challenge"

# Get access token
echo "Getting access token..."
ACCESS_TOKEN=$(gcloud auth print-access-token)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Error: Could not get access token"
  echo "Run: gcloud auth login"
  exit 1
fi

# Challenge number (random for testing)
CHALLENGE_NUM=$((RANDOM % 1000 + 1))
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

echo "Sending test notification..."
echo "Project: $PROJECT_ID"
echo "Topic: $TOPIC"
echo "Challenge: #$CHALLENGE_NUM"

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
  }')

echo "Response: $RESPONSE"

# Check if successful
if echo "$RESPONSE" | grep -q "name"; then
  echo "✅ Notification sent successfully!"
  MESSAGE_ID=$(echo "$RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
  echo "Message ID: $MESSAGE_ID"
else
  echo "❌ Failed to send notification"
  echo "$RESPONSE"
fi
```

## Step 4: Make Script Executable and Run

```bash
# Make executable
chmod +x test-fcm.sh

# Update PROJECT_ID in the script
sed -i '' 's/your-project-id/YOUR_ACTUAL_PROJECT_ID/g' test-fcm.sh

# Run test
./test-fcm.sh
```

## Expected Responses

### Success Response
```json
{
  "name": "projects/your-project/messages/0:1234567890123456%abcdef"
}
```

### Error Responses
```json
// Invalid topic
{
  "error": {
    "code": 400,
    "message": "Invalid topic name",
    "status": "INVALID_ARGUMENT"
  }
}

// Authentication error
{
  "error": {
    "code": 401,
    "message": "Request had invalid authentication credentials",
    "status": "UNAUTHENTICATED"
  }
}
```

## Debugging Tips

1. **Check Topic Subscription**: Ensure your app is subscribed to the topic
2. **Verify Project ID**: Make sure you're using the correct Firebase project ID
3. **Test with Device Token**: Try sending to a specific device first
4. **Check App State**: Notifications behave differently when app is foreground/background
5. **Monitor Logs**: Check Firebase Console > Cloud Messaging for delivery stats

## Alternative: Using Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Send test message (interactive)
firebase messaging:test
```

## Environment Variables Approach

Create a `.env` file for easier testing:

```bash
# .env
FIREBASE_PROJECT_ID=your-project-id
FCM_TOPIC=daily_challenge
```

Then source it in your script:
```bash
source .env
PROJECT_ID=$FIREBASE_PROJECT_ID
TOPIC=$FCM_TOPIC
```
