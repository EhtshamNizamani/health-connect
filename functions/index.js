// Import the necessary Firebase modules
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Create a reference to the Firestore database
const db = admin.firestore();

// Define the region once to reuse it
const europeFunctions = functions.region("europe-west1");

/**
 * ==================================================================
 * 1. FUNCTION TO SEND THE INITIAL CALL INVITATION
 * Triggered by the caller. Sends a notification to the receiver.
 * ==================================================================
 */
exports.sendCallNotification = europeFunctions.https.onCall(
    async (data, context) => {
      // --- Authenticate the request ---
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated.",
        );
      }

      // --- Get and validate data ---
      const {receiverId, callerName, callId} = data;
      if (!receiverId || !callerName || !callId) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Requires 'receiverId', 'callerName', and 'callId'.",
        );
      }

      try {
        // --- Get receiver's & caller's info from Firestore ---
        const receiverDoc = await db
            .collection("users")
            .doc(receiverId).get();
        const callerDoc = await db
            .collection("users")
            .doc(context.auth.uid).get();

        if (!receiverDoc.exists) {
          throw new functions.https.HttpsError(
              "not-found", "Receiver's user document not found.",
          );
        }
        if (!callerDoc.exists) {
          throw new functions.https.HttpsError(
              "not-found", "Caller's user document not found.",
          );
        }

        const {fcmToken} = receiverDoc.data();
        const callerData = callerDoc.data();
        if (!fcmToken) {
          throw new functions.https.HttpsError(
              "unavailable",
              "The receiver does not have a notification token.",
          );
        }

        // --- Construct the ZegoCloud-compliant notification payload ---
        const payload = {
          data: {
            "payload": JSON.stringify({
              "aps": {
                "alert": {
                  "title": `Incoming Call from ${callerName}`,
                  "body": "Tap to answer the video call.",
                },
                "sound": "default",
              },
              "call_id": callId,
              "caller_id": context.auth.uid,
              "caller_name": callerName,
              "caller_photo_url": callerData.photoUrl || "",
              "caller_role": callerData.role || "",
              "type": "video_call_invitation",
              "call_type": "video_call",
              "zego_call_id": callId,
              "zego_uikit_call_version": "2.0.0",
            }),
          },
          token: fcmToken,
          apns: {headers: {"apns-priority": "10"}},
          android: {priority: "high"},
        };

        // --- Send the notification ---
        await admin.messaging().send(payload);

        console.log(`Call invitation sent successfully to ${receiverId}`);
        return {success: true};
      } catch (error) {
        console.error("Error sending call invitation:", error);
        throw new functions.https.HttpsError("internal", error.message, error);
      }
    },
);

/**
 * ==================================================================
 * 2. FUNCTION TO NOTIFY CALLER THAT THE CALL WAS ACCEPTED
 * Triggered by the receiver. Sends a notification back to the caller.
 * ==================================================================
 */
exports.acceptCall = europeFunctions.https.onCall(async (data, context) => {
  // --- Authenticate the request ---
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated", "Must be authenticated.",
    );
  }

  // --- Get and validate data ---
  const {callerId, callId} = data;
  if (!callerId || !callId) {
    throw new functions.https.HttpsError(
        "invalid-argument", "Requires 'callerId' and 'callId'.",
    );
  }

  const accepterId = context.auth.uid;

  try {
    // --- Get accepter's (current user's) details ---
    const accepterDoc = await db.collection("users").doc(accepterId).get();
    if (!accepterDoc.exists) {
      throw new functions.https.HttpsError(
          "not-found", "Accepter's user document not found.",
      );
    }
    const accepterData = accepterDoc.data();

    // --- Get original caller's FCM token ---
    const callerDoc = await db.collection("users").doc(callerId).get();
    if (!callerDoc.exists) {
      throw new functions.https.HttpsError(
          "not-found", "Original caller not found.",
      );
    }
    const {fcmToken} = callerDoc.data();
    if (!fcmToken) {
      console.log("Caller has no FCM token. Cannot send 'accept' signal.");
      return {success: false, message: "Caller has no token."};
    }

    // --- Construct the 'call_accepted' payload with rich data ---
    const message = {
      token: fcmToken,
      data: {
        payload: JSON.stringify({
          "type": "call_accepted",
          "call_id": callId,
          "accepter_id": accepterId,
          "accepter_name": accepterData.name || "User",
          "accepter_role": accepterData.role || "",
          "accepter_photo_url": accepterData.photoUrl || "",
        }),
      },
      // Also send a visual notification
      notification: {
        title: "Call Accepted",
        body: `${accepterData.name || "User"} has joined the call.`,
      },
      android: {priority: "high"},
      apns: {payload: {aps: {"content-available": 1}}},
    };

    // --- Send the 'accept' signal ---
    await admin.messaging().send(message);

    console.log(`'call_accepted' signal sent successfully to ${callerId}`);
    return {success: true};
  } catch (error) {
    console.error("Error sending 'accept' signal:", error);
    throw new functions.https.HttpsError("internal", error.message, error);
  }
});
