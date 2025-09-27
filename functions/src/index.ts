import * as admin from "firebase-admin";
import {wordList} from "./word";
import {onSchedule} from "firebase-functions/scheduler";
import {onCall} from "firebase-functions/https";
import {logger} from "firebase-functions";
import {TwitterApi} from "twitter-api-v2";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Global topic for all Furdle users
const GLOBAL_TOPIC = "daily_challenge";

// Twitter client configuration
const getTwitterClient = () => {
  const appKey = process.env.TWITTER_API_KEY;
  const appSecret = process.env.TWITTER_API_SECRET;
  const accessToken = process.env.TWITTER_ACCESS_TOKEN;
  const accessSecret = process.env.TWITTER_ACCESS_TOKEN_SECRET;

  if (!appKey || !appSecret || !accessToken || !accessSecret) {
    throw new Error("Twitter API credentials not configured");
  }

  return new TwitterApi({
    appKey,
    appSecret,
    accessToken,
    accessSecret,
  });
};

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

// Function to post a tweet about the first completion
async function postFirstCompletionTweet(
  challengeNumber: number,
  attempts: number,
  twitterUsername?: string
): Promise<void> {
  try {
    const twitterClient = getTwitterClient();

    let tweetText = `🎉 FIRST COMPLETION ALERT! 🧩\n\nFurdle Challenge #${challengeNumber} has been cracked in ${attempts} attempt${attempts === 1 ? "" : "s"}! `;

    if (twitterUsername && twitterUsername.trim()) {
      tweetText += `Congratulations @${twitterUsername.replace("@", "")}! 🏆\n\n`;
    } else {
      tweetText += "Amazing work! 🏆\n\n";
    }

    tweetText +=
      "Think you can beat that? Play now at https://furdle.web.app/\n\n#Furdle #WordPuzzle #FirstToSolve";

    const tweet = await twitterClient.v2.tweet(tweetText);

    logger.info("Successfully posted first completion tweet:", {
      challengeNumber,
      attempts,
      twitterUsername,
      tweetId: tweet.data.id,
    });
  } catch (error) {
    logger.error("Error posting first completion tweet:", error);
    // Don't throw - we don't want to fail the completion if Twitter fails
  }
}

// Callable function to report puzzle completion
export const reportCompletion = onCall(async request => {
  try {
    const {challengeId, challengeNumber, attempts, twitterUsername} =
      request.data;

    if (!challengeId || !challengeNumber || !attempts) {
      throw new Error("Missing required parameters");
    }

    const db = admin.firestore();
    const completionRef = db.collection("completions").doc(challengeId);

    // Use a transaction to check if this is the first completion
    const result = await db.runTransaction(async transaction => {
      const completionDoc = await transaction.get(completionRef);

      if (!completionDoc.exists) {
        // This is the first completion!
        const completionData = {
          challengeId,
          challengeNumber,
          firstCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
          firstCompletionAttempts: attempts,
          firstCompletionTwitterUsername: twitterUsername || null,
          totalCompletions: 1,
        };

        transaction.set(completionRef, completionData);
        return {isFirst: true, totalCompletions: 1};
      } else {
        // Not the first, just increment the count
        transaction.update(completionRef, {
          totalCompletions: admin.firestore.FieldValue.increment(1),
        });

        const data = completionDoc.data();
        return {
          isFirst: false,
          totalCompletions: (data?.totalCompletions || 0) + 1,
        };
      }
    });

    if (result.isFirst) {
      // Post the first completion tweet
      await postFirstCompletionTweet(
        challengeNumber,
        attempts,
        twitterUsername
      );

      logger.info("First completion recorded:", {
        challengeId,
        challengeNumber,
        attempts,
        twitterUsername,
      });

      return {
        success: true,
        isFirstCompletion: true,
        message:
          "Congratulations! You're the first to complete this challenge!",
      };
    } else {
      logger.info("Completion recorded:", {
        challengeId,
        challengeNumber,
        totalCompletions: result.totalCompletions,
      });

      return {
        success: true,
        isFirstCompletion: false,
        totalCompletions: result.totalCompletions,
        message: "Completion recorded successfully!",
      };
    }
  } catch (error) {
    logger.error("Error in reportCompletion:", error);
    throw error;
  }
});

// Callable function to get completion stats for a challenge
export const getCompletionStats = onCall(async request => {
  try {
    const {challengeId} = request.data;

    if (!challengeId) {
      throw new Error("Missing challengeId parameter");
    }

    const db = admin.firestore();
    const completionRef = db.collection("completions").doc(challengeId);
    const completionDoc = await completionRef.get();

    if (!completionDoc.exists) {
      return {
        success: true,
        totalCompletions: 0,
        hasFirstCompletion: false,
      };
    }

    const data = completionDoc.data();
    return {
      success: true,
      totalCompletions: data?.totalCompletions || 0,
      hasFirstCompletion: !!data?.firstCompletedAt,
      firstCompletionAttempts: data?.firstCompletionAttempts,
    };
  } catch (error) {
    logger.error("Error in getCompletionStats:", error);
    throw error;
  }
});

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
      const challengeNumber = (data.data()?.number || 0) + 1;

      await docRef.update({
        date: now,
        // increment the number
        number: challengeNumber,
        nextRun: nextRun,
        word: word,
      });

      logger.info("Successfully updated challenge with word:", {word});

      // Initialize completion tracking for the new challenge
      const challengeIdForCompletion = `challenge_${challengeNumber}_${now.getFullYear()}_${now.getMonth() + 1}_${now.getDate()}`;
      const completionRef = db
        .collection("completions")
        .doc(challengeIdForCompletion);

      // Only create if it doesn't exist (in case function runs multiple times)
      const completionDoc = await completionRef.get();
      if (!completionDoc.exists) {
        await completionRef.set({
          challengeId: challengeIdForCompletion,
          challengeNumber,
          createdAt: now,
          totalCompletions: 0,
        });
        logger.info("Initialized completion tracking for challenge:", {
          challengeIdForCompletion,
        });
      }

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
