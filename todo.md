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

#### Basic Features

- [x] Logical and Phsyical key should be in sync
- [x] Keyabord layout should be responsive
- [x] Keyboard state should update and preserved locally
- [x] Game state should be persisted locally for offline mode
- [ ] app does not run on web due to local storage
- [ ] Add firebase push notifications
- [ ] 
### Animations

- [x] Confetti on win
- [ ] Initial render of Grid should be animated with Sound Effect
      All the cells will enter from different directions and laid out in a grid pattern within 3 seconds.
- [ ] Shake on wrong guess
- [ ] Flip Cells on word Submit

## 1. ARCHITECTURE & DEPENDENCIES

### State Management

- [x] Flutter Riverpod 2.6.1+ for state management
- [x] Implement Repository pattern for data sources
- [x] Use AsyncNotifier for complex state management
- [x] Separate UI state from business logic

### Local Storage

- [ ] Add Drift (SQLite) for local database
- [ ] Implement Repository pattern for local storage
- [ ] Add SharedPreferences for simple settings
- [ ] Add device_info_plus for device identification

### Network & Firebase

- [x] Keep existing Firebase Core and Firestore
- [ ] Add connectivity_plus for network status
- [ ] Implement proper error handling for network failures
- [ ] Add retry mechanisms for failed requests

### Additional Dependencies

- [ ] Add freezed for immutable data classes
- [ ] Add json_annotation for JSON serialization
- [ ] Add equatable for value equality
- [ ] Add logger for better debugging
- [ ] Add build_runner for code generation

## 2. DATA LAYER

### Models (with Freezed)

- [ ] Create GameState model (current game progress)
- [ ] Create Puzzle model (word + metadata)
- [ ] Create Stats model (user statistics)
- [ ] Create Settings model (user preferences)
- [ ] Create CellState model (grid cell state)
- [ ] Create KeyboardState model (keyboard colors)

### Data Sources

- [ ] LocalDataSource (Drift database)
  - [ ] Puzzles table (cached daily puzzles)
  - [ ] GameState table (current game state)
  - [ ] Stats table (user statistics)
  - [ ] Settings table (user preferences)
- [ ] RemoteDataSource (Firebase Firestore)
  - [ ] Daily puzzle retrieval
  - [ ] Puzzle metadata sync
- [ ] WordsDataSource (Local word list)
  - [ ] Hardcoded word validation
  - [ ] Random offline puzzle generation

### Repositories

- [ ] PuzzleRepository
  - [ ] getTodaysPuzzle() -> online first, fallback to cached
  - [ ] getRandomPuzzle() -> for offline mode
  - [ ] validateWord() -> check against word list
  - [ ] cachePuzzle() -> store for offline use
- [ ] GameRepository
  - [ ] saveGameState() -> persist current progress
  - [ ] loadGameState() -> resume game
  - [ ] resetGame() -> start new game
  - [ ] submitGuess() -> process user input
- [ ] StatsRepository
  - [ ] updateStats() -> record game completion
  - [ ] getStats() -> retrieve user statistics
  - [ ] resetStats() -> clear all statistics
- [ ] SettingsRepository
  - [ ] getSettings() -> user preferences
  - [ ] updateSettings() -> save preferences

## 3. BUSINESS LOGIC LAYER

### Use Cases

- [ ] GetTodaysPuzzleUseCase
  - [ ] Check network connectivity
  - [ ] Fetch from remote if online
  - [ ] Fallback to cached puzzle
  - [ ] Generate random puzzle if no cache
- [ ] PlayGameUseCase
  - [ ] Load existing game state
  - [ ] Process user guesses
  - [ ] Validate words against dictionary
  - [ ] Update game state
  - [ ] Handle game completion
- [ ] ManageStatsUseCase
  - [ ] Track games played
  - [ ] Calculate win streaks
  - [ ] Update statistics on game end
- [ ] SyncDataUseCase
  - [ ] Sync puzzles when online
  - [ ] Cache for offline use
  - [ ] Handle sync failures gracefully

### Providers (Riverpod)

- [ ] puzzleProvider -> current puzzle state
- [ ] gameStateProvider -> current game progress
- [ ] statsProvider -> user statistics
- [ ] settingsProvider -> user preferences
- [ ] connectivityProvider -> network status
- [ ] wordValidationProvider -> word list management

## 4. PRESENTATION LAYER

### State Notifiers

- [ ] GameNotifier
  - [ ] Manages game state
  - [ ] Handles user input
  - [ ] Validates moves
  - [ ] Triggers state persistence
- [ ] PuzzleNotifier
  - [ ] Loads daily/random puzzles
  - [ ] Handles online/offline scenarios
  - [ ] Manages puzzle caching
- [ ] StatsNotifier
  - [ ] Tracks game statistics
  - [ ] Calculates win rates
  - [ ] Manages historical data
- [ ] SettingsNotifier
  - [ ] Manages user preferences
  - [ ] Handles theme changes
  - [ ] Stores game configurations

### UI Screens

- [ ] GameScreen (main gameplay)
  - [ ] Grid widget for letter tiles
  - [ ] Virtual keyboard
  - [ ] Game status indicators
  - [ ] Win/lose animations
- [ ] StatsScreen
  - [ ] Win/loss statistics
  - [ ] Win streak display
  - [ ] Historical game data
- [ ] SettingsScreen
  - [ ] Theme selection
  - [ ] Difficulty settings (future)
  - [ ] Reset options
- [ ] HelpScreen
  - [ ] Game rules
  - [ ] Color coding explanation
  - [ ] Tips and tricks

### Widgets

- [ ] GameGrid widget
- [ ] LetterTile widget
- [ ] VirtualKeyboard widget
- [ ] StatsCard widget
- [ ] SettingsToggle widget

## 5. FIREBASE FUNCTIONS

### Update Existing Function

- [ ] Fix randomWord() implementation in functions/src/index.ts
- [ ] Add proper error handling
- [ ] Add logging for debugging
- [ ] Test timezone handling (EST midnight)
- [ ] Add puzzle validation

### Enhanced Function Features

- [ ] Add puzzle difficulty metadata
- [ ] Add puzzle themes (future)
- [ ] Add admin controls for manual puzzle setting
- [ ] Add analytics for puzzle difficulty

## 6. OFFLINE/ONLINE STRATEGY

### Online Mode (Preferred)

- [ ] Fetch daily puzzle from Firebase
- [ ] Cache puzzle locally
- [ ] Sync stats periodically
- [ ] Show network status indicator

### Offline Mode (Fallback)

- [ ] Use cached daily puzzle if available
- [ ] Generate random puzzle from word list
- [ ] Store progress locally
- [ ] Sync when connection restored

### Connectivity Handling

- [ ] Monitor network status
- [ ] Graceful degradation
- [ ] Automatic sync on reconnection
- [ ] User feedback for network issues

## 7. GAME LOGIC ENHANCEMENTS

### Core Game Mechanics

- [ ] Configurable word length (default: 5)
- [ ] Configurable attempt count (default: 6)
- [ ] Difficulty modes (easy: 7 attempts, medium: 6, hard: 5)
- [ ] Word validation against dictionary
- [ ] Color coding (green: correct position, yellow: wrong position, gray: not in word)

### State Management

- [ ] Persist game state on every move
- [ ] Resume interrupted games
- [ ] Handle multiple game sessions
- [ ] Validate state integrity

### Statistics Tracking

- [ ] Games played
- [ ] Games won
- [ ] Current win streak
- [ ] Max win streak
- [ ] Average attempts for wins
- [ ] Win distribution by attempt count

## 8. DATA PERSISTENCE

### Local Database Schema (Drift)

```sql
-- Puzzles table
CREATE TABLE puzzles (
  id INTEGER PRIMARY KEY,
  date TEXT UNIQUE,
  word TEXT,
  number INTEGER,
  difficulty TEXT,
  source TEXT, -- 'daily', 'random'
  created_at TEXT
);

-- Game states table
CREATE TABLE game_states (
  id INTEGER PRIMARY KEY,
  puzzle_id INTEGER,
  grid_state TEXT, -- JSON
  keyboard_state TEXT, -- JSON
  current_row INTEGER,
  current_col INTEGER,
  status TEXT, -- 'playing', 'won', 'lost'
  attempts INTEGER,
  created_at TEXT,
  updated_at TEXT,
  FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
);

-- Statistics table
CREATE TABLE statistics (
  id INTEGER PRIMARY KEY,
  games_played INTEGER,
  games_won INTEGER,
  current_streak INTEGER,
  max_streak INTEGER,
  win_distribution TEXT, -- JSON array
  last_updated TEXT
);

-- Settings table
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT
);
```

### SharedPreferences Keys

- [ ] user_device_id
- [ ] theme_mode
- [ ] sound_enabled
- [ ] haptic_enabled
- [ ] last_sync_timestamp

## 9. ERROR HANDLING & RESILIENCE

### Network Errors

- [ ] Graceful degradation to offline mode
- [ ] Retry mechanisms with exponential backoff
- [ ] User-friendly error messages
- [ ] Automatic recovery when connection restored

### Data Integrity

- [ ] Validate loaded game states
- [ ] Handle corrupted data gracefully
- [ ] Backup and restore mechanisms
- [ ] State migration for app updates

### User Experience

- [ ] Loading states for async operations
- [ ] Progress indicators
- [ ] Offline mode indicators
- [ ] Error state recovery options

## 10. TESTING STRATEGY

### Unit Tests

- [ ] Repository tests
- [ ] Use case tests
- [ ] Model serialization tests
- [ ] Game logic tests

### Widget Tests

- [ ] Screen widget tests
- [ ] Custom widget tests
- [ ] User interaction tests

### Integration Tests

- [ ] End-to-end game flow
- [ ] Offline/online transitions
- [ ] Data persistence tests
- [ ] Firebase integration tests

## 11. PERFORMANCE OPTIMIZATIONS

### State Management

- [ ] Efficient provider scoping
- [ ] Minimize rebuilds
- [ ] Lazy loading for heavy operations
- [ ] Proper disposal of resources

### Data Operations

- [ ] Batch database operations
- [ ] Efficient JSON parsing
- [ ] Image asset optimization
- [ ] Memory management

### UI Performance

- [ ] Optimized animations
- [ ] Efficient grid rendering
- [ ] Smooth transitions
- [ ] Responsive design

## 12. MIGRATION FROM CURRENT VERSION

### Data Migration

- [ ] Export current user stats
- [ ] Migrate game state format
- [ ] Convert existing settings
- [ ] Preserve user progress

### Feature Parity

- [ ] Maintain existing UI/UX
- [ ] Keep current color scheme
- [ ] Preserve game mechanics
- [ ] Maintain Firebase compatibility

### Gradual Rollout

- [ ] Feature flags for new functionality
- [ ] A/B testing for major changes
- [ ] Fallback to legacy code if needed
- [ ] User feedback collection

## Implementation Priority

### Phase 1: Foundation (Week 1-2)

1. Set up new dependencies
2. Create core models with Freezed
3. Set up Drift database
4. Implement basic repositories

### Phase 2: Core Functionality (Week 3-4)

1. Implement game logic
2. Create game state management
3. Build basic UI screens
4. Add offline word list

### Phase 3: Online Integration (Week 5)

1. Integrate Firebase functions
2. Implement sync logic
3. Add connectivity handling
4. Test online/offline transitions

### Phase 4: Polish & Testing (Week 6)

1. Add animations and polish
2. Implement comprehensive testing
3. Performance optimization
4. User feedback integration

### Phase 5: Migration & Deployment (Week 7)

1. Data migration tools
2. Gradual feature rollout
3. Production deployment
4. Monitor and iterate

---

This implementation plan provides a comprehensive roadmap for rebuilding Furdle with modern architecture, proper state management, and robust offline/online functionality while maintaining the core game experience.
