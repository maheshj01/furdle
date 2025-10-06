# Firebase Functions for Furdle

This directory contains Firebase Cloud Functions for the Furdle word puzzle game.

## Functions

### publishChallenge

- **Trigger**: Scheduled (daily at midnight UTC)
- **Purpose**: Creates a new daily challenge with a random word
- **Features**:
  - Updates Firestore with new challenge data
  - Sends push notifications to all subscribed users via FCM topics
  - Removes used words from the word list
  - Tracks challenge numbers and timing
  - Initializes completion tracking for the new challenge

### reportCompletion

- **Trigger**: HTTPS Callable
- **Purpose**: Reports puzzle completion and handles first completion detection
- **Features**:
  - Tracks first completion of each daily challenge
  - Posts celebratory tweet when someone is first to solve
  - Optionally mentions user's Twitter handle
  - Maintains completion statistics

### getCompletionStats

- **Trigger**: HTTPS Callable
- **Purpose**: Retrieves completion statistics for a challenge
- **Features**:
  - Returns total completion count
  - Indicates if first completion has occurred
  - Provides first completion attempt count

## Development

```bash
# Install dependencies
npm install

# Lint and format code
npm run lint          # Check for lint errors
npm run lint:fix      # Fix auto-fixable lint errors
npm run format        # Format code with Prettier
npm run format:check  # Check if code is formatted
npm run precommit     # Format and lint (run before commits)

# Build and test
npm run build         # Compile TypeScript
npm run serve         # Start Firebase emulator
npm run deploy        # Deploy to Firebase
```

## Environment Configuration

### Twitter API Setup

To enable Twitter functionality, configure secrets for Firebase Functions:

```bash
# Set Twitter API credentials
firebase functions:secrets:set X_API_KEY
firebase functions:secrets:set X_API_SECRET
firebase functions:secrets:set X_ACCESS_TOKEN
firebase functions:secrets:set X_ACCESS_TOKEN_SECRET
```

_Test posting a tweet_

```bash
firebase functions:shell
firebase> testTweet({data: {challengeNumber: 123, attempts: 2, twitterUsername: 'testuser'}})
```

### Pre-commit Checks

Run `npm run precommit` before committing to ensure code quality.

## Notification System

The functions send push notifications using Firebase Cloud Messaging (FCM) topics:

- **Topic**: `daily_challenge`
- **Subscribers**: All app users who have enabled notifications
- **Payload**: Challenge number, timestamp, and action data

### Quick Test

1. select project

```bash
gcloud auth login
gcloud config set project furdle
```

2. send test notification to a topic

```bash
mahesh@MacBook-Pro-81 functions % ACCESS_TOKEN=$(gcloud auth print-access-token)
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/furdle/messages:send" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "daily_challenge",
      "notification": {
        "title": "<0001f9e9> Test Notification",
        "body": "Testing from curl!"
      }
    }
  }'
```
