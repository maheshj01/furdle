- [X] SettingsService and GameService should be separate
- [X] GameService should only talk to the server or local storage
- [X] SettingsService should only talk to local storage and game settings
- [X] SettingsController should only talk to SettingsService

- [ ] When the GameService is initialized it should load the game from local storage
- [ ] if there is no game in local storage it should load a new game from the server
- [ ] The GameService should have a method to load a new game from the server
- [ ] If a game is available in local storage
        check if the game is finished
        if the game is finished check if new game is available on the server
            if new game is available load new game from server
        else if the game is not finished load the game from local storage
     else
        load new game from server
- [ ] The game saves the GameState to local storage
- [ ] Puzzle and GameState class should be separate and do only one thing
- [ ] GameState stores teh current state of the game including the current puzzle and the keyboard state
- [ ] Every move should be saved to the GameState