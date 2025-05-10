/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// import { onRequest } from "firebase-functions/v2/https";
// import logger from "firebase-functions/logger";

// const {pubsub} = require("firebase-functions");
// const admin = require("firebase-admin");
// const {firestore} = admin;
// admin.initializeApp();

// exports.deleteOldUrgentDocs = pubsub
//     .schedule("every 3 minutes")
//     .onRun(async (context) => {
//       const cutoff = Date.now() - 60 * 3000;
//       const snapshot = await firestore()
//           .collection("locations")
//           .doc("urgentLocations")
//           .collection("urgent_locations")
//           .where("createdAt", "<=", new Date(cutoff))
//           .get();

//       const deletions = snapshot.docs.map((doc) => doc.ref.delete());
//       await Promise.all(deletions);
//       console.log(`Deleted ${deletions.length} outdated docs.`);
//     });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
exports.deleteOldUrgentDocs = functions.pubsub
    .schedule("every 3 minutes")
    .onRun(async (context) => {
      try {
        // 1 minute ago
        const cutoff = admin.firestore.Timestamp.fromMillis(Date.now()-60*1000);
        console.log("Cutoff Timestamp:", cutoff.toDate());
        const snapshot = await db
            .collection("locations")
            .doc("urgentLocations")
            .collection("urgent_locations")
            .where("createdAt", "<=", cutoff)
            .get();
        console.log("Found docs to delete:", snapshot.size);
        const deletions = snapshot.docs.map((doc) => doc.ref.delete());
        await Promise.all(deletions);
        console.log(`Deleted ${deletions.length} outdated docs.`);
      } catch (error) {
        console.error("Error deleting old urgent docs:", error);
      }
    });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
