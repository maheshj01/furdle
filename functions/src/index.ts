import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {wordList} from "./word";
import {onSchedule} from "firebase-functions/scheduler";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp(functions.config().firebase);

// pick a random word from the list
function randomWord(arr: string[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// Runs every 24 hours UTC
export const publishChallenge = onSchedule(
    "0 0 * * *",
    async (event) => {
      try {
        const db = admin.firestore();
        const docRef = db.collection("furdle").doc("stats");
        const data = await docRef.get();
        console.log("Running scheduled function", data);

        // now in UTC
        const now = new Date();
        // next run is 24 hours from now
        const nextRun = new Date(now.getTime() + 24 * 60 * 60 * 1000);
        const word = randomWord(wordList);

        // remove the word from the list
        wordList.splice(wordList.indexOf(word), 1);
        console.log("Word list length", wordList.length);

        // Alternative approach using Timestamp.fromDate for both timestamps
        await docRef.update({
          date: now,
          // increment the number
          number: data.data()?.number + 1,
          nextRun: nextRun,
          word: word,
        });

        console.log("Successfully updated challenge with word:", word);
      } catch (error) {
        console.error("Error in publishChallenge:", error);
        throw error;
      }
    }
);
