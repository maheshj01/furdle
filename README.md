# Furdle (Flutter + Wordle) v0.4.3

An open sourced wordle built with flutter. A new puzzle is available every day midnight UTC.

- Play Local game or Daily challenge
- Get notifications for daily puzzle
- Supports physical keyboard input
- Take your time to solve the puzzle, continue exactly where you left off.
- Supports Dark mode and light mode
- Share puzzle results only on completion of Daily challenge
- Runs on all platforms (Android, iOS, Web, Desktop)
<!-- - Different Difficulty mode (easy, medium ,hard) -->

### Structure of each game state

```json
  {
    id: 1760062672,
    gameType: 1,
    size: { width: 5, height: 6 },
    row: 6,
    column: 0,
    status: 3,
    targetWord: storm,
    currentWord,
    submittedWords: [slang, class, plane, scale, trash, slack],
    cells:
      [
        [
          { character: S, cellType: 1 },
          { character: L, cellType: 3 },
          { character: A, cellType: 3 },
          { character: N, cellType: 3 },
          { character: G, cellType: 3 },
        ],
        [
          { character: C, cellType: 3 },
          { character: L, cellType: 3 },
          { character: A, cellType: 3 },
          { character: S, cellType: 2 },
          { character: S, cellType: 3 },
        ],
        [
          { character: P, cellType: 3 },
          { character: L, cellType: 3 },
          { character: A, cellType: 3 },
          { character: N, cellType: 3 },
          { character: E, cellType: 3 },
        ],
        [
          { character: S, cellType: 1 },
          { character: C, cellType: 3 },
          { character: A, cellType: 3 },
          { character: L, cellType: 3 },
          { character: E, cellType: 3 },
        ],
        [
          { character: T, cellType: 2 },
          { character: R, cellType: 2 },
          { character: A, cellType: 3 },
          { character: S, cellType: 2 },
          { character: H, cellType: 3 },
        ],
        [
          { character: S, cellType: 1 },
          { character: L, cellType: 3 },
          { character: A, cellType: 3 },
          { character: C, cellType: 3 },
          { character: K, cellType: 3 },
        ],
      ],
    difficulty: 1,
    startTime: 1760062672107,
    endTime: null,
    hintsUsed: 0,
    nextGameDate: 1760140806758,
  },
```

### Can you crack the todays furdle?

Try it out https://furdle.web.app/

FURDLE #125 6/6

🟨⬛️⬛️⬛️⬛️<br>
⬛️🟩⬛️⬛️🟩<br>
⬛️⬛️⬛️🟩🟩<br>
⬛️🟩⬛️🟩🟩<br>
⬛️🟩🟩⬛️🟩<br>
🟩🟩🟩🟩🟩<br>

<img width="1176" alt="image" src="https://user-images.githubusercontent.com/31410839/152667914-8d4c1458-d1ad-4783-8440-47a74eadc385.png">

### Android v0.4.3

<a href="https://play.google.com/store/apps/details?id=com.wml.furdle" target="_blank">
<img src="https://user-images.githubusercontent.com/31410839/152287114-5d384a72-70af-444d-b832-f5aadff6fa16.png" height="60">
</a>
