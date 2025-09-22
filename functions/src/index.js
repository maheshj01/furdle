"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.publishChallenge = void 0;
var admin = require("firebase-admin");
var word_1 = require("./word");
var scheduler_1 = require("firebase-functions/scheduler");
var firebase_functions_1 = require("firebase-functions");
// Initialize Firebase Admin SDK
admin.initializeApp();
// Global topic for all Furdle users
var GLOBAL_TOPIC = "daily_challenge";
// pick a random word from the list
function randomWord(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
}
// Send notifications to topic subscribers
function sendNotificationToTopic(topic_1, title_1, body_1) {
    return __awaiter(this, arguments, void 0, function (topic, title, body, data) {
        var message, response, error_1;
        if (data === void 0) { data = {}; }
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    _a.trys.push([0, 2, , 3]);
                    message = {
                        topic: topic,
                        notification: {
                            title: title,
                            body: body,
                        },
                        data: __assign(__assign({}, data), { click_action: "FLUTTER_NOTIFICATION_CLICK" }),
                        android: {
                            notification: {
                                channelId: "furdle_notifications",
                                priority: "high",
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
                    return [4 /*yield*/, admin.messaging().send(message)];
                case 1:
                    response = _a.sent();
                    firebase_functions_1.logger.info("Successfully sent notification to topic '".concat(topic, "': ").concat(response));
                    return [3 /*break*/, 3];
                case 2:
                    error_1 = _a.sent();
                    firebase_functions_1.logger.error("Error sending notification to topic '".concat(topic, "':"), error_1);
                    throw error_1;
                case 3: return [2 /*return*/];
            }
        });
    });
}
// Runs every 24 hours UTC
exports.publishChallenge = (0, scheduler_1.onSchedule)({
    schedule: "0 0 * * *",
    timeZone: "UTC",
}, function (event) { return __awaiter(void 0, void 0, void 0, function () {
    var db, docRef, data, now, nextRun, word, challengeNumber, error_2;
    var _a;
    return __generator(this, function (_b) {
        switch (_b.label) {
            case 0:
                _b.trys.push([0, 4, , 5]);
                db = admin.firestore();
                docRef = db.collection("furdle").doc("stats");
                return [4 /*yield*/, docRef.get()];
            case 1:
                data = _b.sent();
                firebase_functions_1.logger.info("Running scheduled function", { data: data.data() });
                now = new Date();
                nextRun = new Date(now.getTime() + 24 * 60 * 60 * 1000);
                word = randomWord(word_1.wordList);
                // remove the word from the list
                word_1.wordList.splice(word_1.wordList.indexOf(word), 1);
                firebase_functions_1.logger.info("Word list length", { length: word_1.wordList.length });
                challengeNumber = (((_a = data.data()) === null || _a === void 0 ? void 0 : _a.number) || 0) + 1;
                return [4 /*yield*/, docRef.update({
                        date: now,
                        // increment the number
                        number: challengeNumber,
                        nextRun: nextRun,
                        word: word,
                    })];
            case 2:
                _b.sent();
                firebase_functions_1.logger.info("Successfully updated challenge with word:", { word: word });
                // Send notification to all topic subscribers about the new challenge
                return [4 /*yield*/, sendNotificationToTopic(GLOBAL_TOPIC, "🧩 New Furdle Challenge!", "Challenge #".concat(challengeNumber, " is now available. Can you solve today's word?"), {
                        action: "new_challenge",
                        challengeNumber: challengeNumber.toString(),
                        // Don't include the actual word in production notifications
                        timestamp: now.toISOString(),
                    })];
            case 3:
                // Send notification to all topic subscribers about the new challenge
                _b.sent();
                firebase_functions_1.logger.info("Notification sent to topic for challenge:", {
                    challengeNumber: challengeNumber,
                    topic: GLOBAL_TOPIC,
                });
                return [3 /*break*/, 5];
            case 4:
                error_2 = _b.sent();
                firebase_functions_1.logger.error("Error in publishChallenge:", error_2);
                throw error_2;
            case 5: return [2 /*return*/];
        }
    });
}); });
