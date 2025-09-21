import * as admin from "firebase-admin";
import {wordList} from "./word";
import {onSchedule} from "firebase-functions/scheduler";
import {logger} from "firebase-functions";

// Initialize Firebase Admin SDK
admin.initializeApp();

// pick a random word from the list
function randomWord(arr: string[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// Runs every 24 hours UTC
export const publishChallenge = onSchedule({
  schedule: "0 0 * * *",
  timeZone: "UTC",
}, async (event) => {
  try {
    const db = admin.firestore();
    const docRef = db.collection("furdle").doc("stats");
    const data = await docRef.get();
    logger.info("Running scheduled function", {data: data.data()});

    // now in UTC
    const now = new Date();
    // next run is 24 hours from now
    const nextRun = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const word = randomWord(wordList);

    // remove the word from the list
    wordList.splice(wordList.indexOf(word), 1);
    logger.info("Word list length", {length: wordList.length});

    // Alternative approach using Timestamp.fromDate for both timestamps
    await docRef.update({
      date: now,
      // increment the number
      number: (data.data()?.number || 0) + 1,
      nextRun: nextRun,
      word: word,
    });

    logger.info("Successfully updated challenge with word:", {word});
  } catch (error) {
    logger.error("Error in publishChallenge:", error);
    throw error;
  }
});
