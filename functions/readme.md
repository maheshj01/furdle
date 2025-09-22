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

## Code Quality

This project uses:

- **ESLint** with Google style guide for linting
- **Prettier** for consistent code formatting
- **TypeScript** for type safety
- **Auto-formatting** on save (when using VS Code)

### VS Code Setup

The `.vscode/` directory contains:

- `settings.json` - Auto-format on save configuration
- `extensions.json` - Recommended extensions

### Pre-commit Checks

Run `npm run precommit` before committing to ensure code quality.

## Notification System

The functions send push notifications using Firebase Cloud Messaging (FCM) topics:

- **Topic**: `daily_challenge`
- **Subscribers**: All app users who have enabled notifications
- **Payload**: Challenge number, timestamp, and action data
