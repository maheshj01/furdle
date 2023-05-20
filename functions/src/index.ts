import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {wordList} from "./word";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp(functions.config().firebase);

function randomWord(arr: string[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// Runs every 24 hours UTC
exports.scheduledFunction = functions.pubsub
    .schedule("0 0 * * *") // midnight every day
// Coordinated Universal Time (UTC) is the primary time standard by which
// the world regulates clocks and time. It is within about 1 second of mean
// solar time at 0° longitude, and is not adjusted for daylight saving time.
    .timeZone("UTC")
    .onRun(async () => {
      const docRef = await admin.firestore().collection("furdle").doc("stats");
      const now = admin.firestore.Timestamp.now();
      // next run is 24 hours from now
      const nextRun = now.toMillis() + 24 * 60 * 60 * 1000;
      return await docRef.update({
        date: admin.firestore.Timestamp.now(),
        number: admin.firestore.FieldValue.increment(1),
        nextRun: admin.firestore.Timestamp.fromMillis(nextRun),
        word: randomWord(wordList),
      });
    });
