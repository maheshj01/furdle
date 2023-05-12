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

// Runs every 6 hours IST
exports.scheduledFunction = functions.pubsub
    .schedule("0 0 * * *") // midnight every day
    .timeZone("Asia/Kolkata")
    .onRun(async () => {
      const docRef = await admin.firestore().collection("furdle").doc("stats");
      return await docRef.update({
        date: admin.firestore.Timestamp.now(),
        number: admin.firestore.FieldValue.increment(1),
        word: randomWord(wordList),
      });
    });
