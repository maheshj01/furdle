import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp(functions.config().firebase);

function randomWord(arr:string[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

exports.scheduledFunction = functions.pubsub
    .schedule("0 0 * * *")
    .timeZone("Asia/Kolkata")
    .onRun(async () => {
      const docRef = await admin.firestore().collection("furdle").doc("stats");
      return await docRef.update({
        date: new Date(),
        number: admin.firestore.FieldValue.increment(1),
        word: randomWord(wordList),
      });
    });
