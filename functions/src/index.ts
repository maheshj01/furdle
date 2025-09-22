import * as admin from "firebase-admin";
import { wordList } from "./word";
import { onSchedule } from "firebase-functions/scheduler";
import { logger } from "firebase-functions";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Global topic for all Furdle users
const GLOBAL_TOPIC = "daily_challenge";

// pick a random word from the list
function randomWord(arr: string[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

// Send notifications to topic subscribers
async function sendNotificationToTopic(
  topic: string,
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<void> {
  try {
    // Create the notification payload
    const message: admin.messaging.Message = {
      topic: topic,
      notification: {
        title: title,
        body: body,
      },
      data: {
        ...data,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        notification: {
          channelId: "furdle_notifications",
          priority: "high" as const,
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: "ic_notification",
          color: "#6200EE",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send the notification to topic
    const response = await admin.messaging().send(message);

    logger.info(
      `Successfully sent notification to topic '${topic}': ${response}`
    );
  } catch (error) {
    logger.error(`Error sending notification to topic '${topic}':`, error);
    throw error;
  }
}

// Runs every 24 hours UTC
export const publishChallenge = onSchedule(
  {
    // runs every day at midnight UTC
    schedule: "0 0 * * *",
    timeZone: "UTC",
  },
  async event => {
    try {
      const db = admin.firestore();
      const docRef = db.collection("furdle").doc("stats");
      const data = await docRef.get();
      logger.info("Running scheduled function", { data: data.data() });

      // now in UTC
      const now = new Date();
      // next run is 24 hours from now
      const nextRun = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const word = randomWord(wordList);

      // remove the word from the list
      wordList.splice(wordList.indexOf(word), 1);
      logger.info("Word list length", { length: wordList.length });

      // Alternative approach using Timestamp.fromDate for both timestamps
      const challengeNumber = (data.data()?.number || 0) + 1;

      await docRef.update({
        date: now,
        // increment the number
        number: challengeNumber,
        nextRun: nextRun,
        word: word,
      });

      logger.info("Successfully updated challenge with word:", { word });

      // Send notification to all topic subscribers about the new challenge
      await sendNotificationToTopic(
        GLOBAL_TOPIC,
        "🧩 New Furdle Challenge!",
        `Challenge #${challengeNumber} is now available. Can you solve today's word?`,
        {
          action: "new_challenge",
          challengeNumber: challengeNumber.toString(),
          // Don't include the actual word in production notifications
          timestamp: now.toISOString(),
        }
      );

      logger.info("Notification sent to topic for challenge:", {
        challengeNumber,
        topic: GLOBAL_TOPIC,
      });
    } catch (error) {
      logger.error("Error in publishChallenge:", error);
      throw error;
    }
  }
);
