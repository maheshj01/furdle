# Firebase Topic Notification Testing Guide

## Quick Start

### Prerequisites
1. Install Google Cloud CLI: `gcloud auth login`
2. Make sure you're authenticated to your Firebase project

### Instant Test (One Command)
```bash
# Run from functions/ directory
./quick-test.sh
```

### Full Featured Test
```bash
# Run from functions/ directory  
./test-fcm.sh
```

## Manual curl Commands

### Basic Test
```bash
# Set your access token
ACCESS_TOKEN=$(gcloud auth print-access-token)

# Send notification
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/furdle/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "daily_challenge",
      "notification": {
        "title": "🧩 Test Notification",
        "body": "Testing from curl!"
      }
    }
  }'
```

### Production-like Test (Matching Your Function)
```bash
ACCESS_TOKEN=$(gcloud auth print-access-token)

curl -X POST \
  "https://fcm.googleapis.com/v1/projects/furdle/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "daily_challenge",
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

## Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `quick-test.sh` | One-liner test | `./quick-test.sh` |
| `test-fcm.sh` | Full-featured test with error handling | `./test-fcm.sh` |

## Configuration

### Current Settings
- **Project ID**: `furdle`
- **Topic**: `daily_challenge`
- **Notification Channel**: `furdle_notifications`

### Customization
Edit the scripts to change:
- Topic name
- Notification content
- Android/iOS specific settings

## Troubleshooting

### Common Issues

1. **Authentication Error**
   ```bash
   gcloud auth login
   gcloud config set project furdle
   ```

2. **Topic Not Found**
   - Make sure your app subscribes to the topic
   - Check topic name spelling

3. **No Notification Received**
   - App must be subscribed to topic
   - Check if app is in foreground (notifications may not show)
   - Verify notification permissions

4. **Permission Denied**
   ```bash
   gcloud auth application-default login
   ```

### Debugging Steps

1. **Check Firebase Console**
   - Go to Cloud Messaging section
   - View delivery statistics
   - Check for errors

2. **Test with Device Token First**
   ```bash
   # Get device token from your app logs
   DEVICE_TOKEN="your_device_token_here"
   
   curl -X POST \
     "https://fcm.googleapis.com/v1/projects/furdle/messages:send" \
     -H "Authorization: Bearer ${ACCESS_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{
       "message": {
         "token": "'${DEVICE_TOKEN}'",
         "notification": {
           "title": "Direct Test",
           "body": "Testing direct to device"
         }
       }
     }'
   ```

3. **Verify Topic Subscription**
   - Check app logs for topic subscription success
   - Ensure `FirebaseMessaging.instance.subscribeToTopic("daily_challenge")` is called

## Response Examples

### Success
```json
{
  "name": "projects/furdle/messages/0:1234567890123456%abcdef"
}
```

### Error
```json
{
  "error": {
    "code": 400,
    "message": "Invalid topic name",
    "status": "INVALID_ARGUMENT"
  }
}
```

## Integration with Your Function

Your `publishChallenge` function sends notifications with this payload:
- **Topic**: `daily_challenge` 
- **Title**: "🧩 New Furdle Challenge!"
- **Body**: "Challenge #X is now available. Can you solve today's word?"
- **Data**: `action`, `challengeNumber`, `timestamp`

The test scripts match this format for realistic testing.
