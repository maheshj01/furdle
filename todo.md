# FURDLE REBUILD - Implementation Plan

## Project Overview

Rebuilding Furdle from scratch with modern Flutter architecture, Riverpod state management, and robust offline/online functionality.

### Core Requirements

- 5-letter word guessing game (configurable in future)
- 6 attempts max (configurable in future)
- Daily puzzles from Firebase Functions
- Offline mode with local puzzles
- Stats tracking (games played, win streak)
- State persistence for resuming games

### Bugs & Improvements

- [ ] Dark mode theme issue with black color grid cell
- [ ] Keyboard layout is difficult to use on mobile devices
- [ ] Show Details about the word on Game Over (Nested Dialog)


#### Basic Features

- [x] Logical and Phsyical key should be in sync
- [x] Keyabord layout should be responsive
- [x] Keyboard state should update and preserved locally
- [x] Game state should be persisted locally for offline mode
- [x] app does not run on web due to local storage
- [x] Add firebase push notifications
- [ ] Add firebase analytics
- [ ] Add firebase crashlytics

### Animations

- [x] Confetti on win
- [ ] Initial render of Grid should be animated with Sound Effect
      All the cells will enter from different directions and laid out in a grid pattern within 3 seconds.
- [ ] Shake on short or invalid word
- [ ] Flip Cells on word Submit

### Theme Settings

- [x] Add Dark Mode
- [ ] Add System Default Mode
- [ ]

### Streak Tracking

- [ ] Maintain a List of Streaks for each user
- [ ] Update the Streak on Game Over
