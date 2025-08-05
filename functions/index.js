// Import the necessary Firebase modules
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// Define the region once to reuse it
const europeFunctions = functions.region("europe-west1");

/**
 * ==================================================================
 * 1. SEND INITIAL CALL INVITATION
 * Triggered by the caller. Sends a notification to the receiver.
 * ==================================================================
 */
exports.sendCallNotification = europeFunctions.https.onCall(
    async (data, context) => {
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated", "User must be authenticated.",
        );
      }
      const {receiverId, callerName, callId} = data;
      if (!receiverId || !callerName || !callId) {
        throw new functions.https.HttpsError(
            "invalid-argument", "Missing required data.",
        );
      }
      try {
        const callerId = context.auth.uid;
        const callerDoc = await db.collection("users").doc(callerId).get();
        const receiverDoc = await db.collection("users").doc(receiverId).get();
        if (!callerDoc.exists || !receiverDoc.exists) {
          throw new functions.https.HttpsError("not-found", "User not found.");
        }
        const {fcmToken} = receiverDoc.data();
        if (!fcmToken) {
          return {success: false, error: "Receiver has no FCM token."};
        }
        const callerData = callerDoc.data();
        const message = {
          token: fcmToken,
          data: {
            payload: JSON.stringify({
              type: "video_call_invitation",
              call_id: callId,
              caller_id: callerId,
              caller_name: callerName,
              caller_photo_url: callerData.photoUrl || "",
              caller_role: callerData.role || "",
            }),
          },
          notification: {
            title: `Incoming Call from ${callerName}`,
            body: "Tap to answer the video call.",
          },
          android: {priority: "high"},
          apns: {payload: {aps: {"sound": "default", "content-available": 1}}},
        };
        await admin.messaging().send(message);
        await db.collection("calls").doc(callId).set({
          callId,
          callerId,
          callerName,
          receiverId,
          status: "calling",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {success: true};
      } catch (error) {
        console.error("sendCallNotification Error:", error);
        throw new functions.https.HttpsError("internal", error.message);
      }
    },
);

/**
 * ==================================================================
 * 2. SEND "CALL ACCEPTED" SIGNAL
 * ==================================================================
 */
exports.acceptCall = europeFunctions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required.");
  }
  const {callerId, callId} = data;
  const accepterId = context.auth.uid;
  if (!callerId || !callId) {
    throw new functions.https
        .HttpsError("invalid-argument", "Required data missing.");
  }
  try {
    const accepterDoc = await db.collection("users").doc(accepterId).get();
    const callerDoc = await db.collection("users").doc(callerId).get();
    if (!accepterDoc.exists || !callerDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found.");
    }
    const {fcmToken} = callerDoc.data();
    if (!fcmToken) {
      return {success: false, error: "Caller has no FCM token."};
    }
    const accepterData = accepterDoc.data();
    const message = {
      token: fcmToken,
      data: {
        payload: JSON.stringify({
          type: "call_accepted",
          call_id: callId,
          accepter_id: accepterId,
          accepter_name: accepterData.name || "User",
          accepter_photo_url: accepterData.photoUrl || "",
        }),
      },
      notification: {
        title: "Call Accepted",
        body: `${accepterData.name || "User"} has joined the call.`,
      },
      android: {priority: "high"},
      apns: {payload: {aps: {"content-available": 1}}},
    };
    await admin.messaging().send(message);
    await db.collection("calls").doc(callId).update({
      status: "accepted",
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {success: true};
  } catch (error) {
    console.error("acceptCall Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * ==================================================================
 * 3. SEND "CALL DECLINED" SIGNAL
 * ==================================================================
 */
exports.declineCall = europeFunctions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required.");
  }
  const {callerId, callId} = data;
  if (!callerId || !callId) {
    throw new functions.https
        .HttpsError("invalid-argument", "Required data missing.");
  }
  try {
    const declinerId = context.auth.uid;
    const declinerDoc = await db.collection("users").doc(declinerId).get();
    if (!declinerDoc.exists) {
      throw new functions.https.HttpsError(
          "not-found", "Decliner's user document not found.",
      );
    }
    const declinerData = declinerDoc.data();
    const callerDoc = await db.collection("users").doc(callerId).get();
    if (!callerDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found.");
    }
    const {fcmToken} = callerDoc.data();
    if (!fcmToken) {
      return {success: false, error: "Caller has no FCM token."};
    }
    // --- THE FIX: Add the decliner's name to the payload ---
    const message = {
      token: fcmToken,
      data: {
        payload: JSON.stringify({
          type: "call_declined",
          call_id: callId,
          decliner_id: declinerId,
          decliner_name: declinerData.name || "User",
        }),
      },
      notification: {
        title: "Call Declined",
        body: `${declinerData.name || "Someone"} declined your call.`,
      },
    };
    await admin.messaging().send(message);
    await db.collection("calls").doc(callId).update({
      status: "declined",
      declinedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {success: true};
  } catch (error) {
    console.error("declineCall Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * ==================================================================
 * 4. SEND "CALL ENDED" SIGNAL
 * ==================================================================
 */
exports.endCall = europeFunctions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Auth required.");
  }
  const {otherUserId, callId, chatRoomId, duration} = data;
  if (!otherUserId || !callId || !chatRoomId) {
    throw new functions.https
        .HttpsError("invalid-argument", "Required data missing.");
  }
  try {
    const otherUserDoc = await db.collection("users").doc(otherUserId).get();
    if (otherUserDoc.exists) {
      const {fcmToken} = otherUserDoc.data();
      if (fcmToken) {
        const message = {
          token: fcmToken,
          data: {
            payload: JSON.stringify({type: "call_ended", call_id: callId}),
          },
        };
        await admin.messaging().send(message);
      }
    }
    await db.collection("calls").doc(callId).update({
      status: "ended",
      endedAt: admin.firestore.FieldValue.serverTimestamp(),
      endedBy: context.auth.uid,
      duration: duration || 0,
    });
    const systemMessage = {
      senderId: "system",
      receiverId: "system",
      content: `Video call ended. Duration: ${duration || "N/A"}`,
      type: "system_call_ended",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection("chats").doc(chatRoomId)
        .collection("messages").add(systemMessage);
    await db.collection("chats").doc(chatRoomId).update({
      lastMessage: "Video call ended",
      lastMessageTimestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {success: true};
  } catch (error) {
    console.error("endCall Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
// ==================================================================
// 5. SEND "CALL CANCELLED" SIGNAL (from caller)
// ==================================================================
exports.cancelCall = europeFunctions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https
        .HttpsError("unauthenticated", "Auth required.");
  }
  const {receiverId, callId} = data;
  if (!receiverId || !callId) {
    throw new functions.https
        .HttpsError("invalid-argument", "Required data missing.");
  }

  try {
    // <<<--- THE FIX: Get the caller's data ---
    const callerId = context.auth.uid;
    const callerDoc = await db.collection("users").doc(callerId).get();
    if (!callerDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Caller not found.");
    }
    const callerData = callerDoc.data();
    // <<<------------------------------------->>>

    const receiverDoc = await db.collection("users").doc(receiverId).get();
    if (!receiverDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Receiver not found.");
    }
    const {fcmToken} = receiverDoc.data();
    if (!fcmToken) {
      return {success: false, error: "Receiver has no FCM token."};
    }
    const message = {
      token: fcmToken,
      data: {
        payload: JSON.stringify({
          type: "call_cancelled",
          call_id: callId,
          caller_id: callerId, // Good to send this too
          caller_name: callerData.name || "Caller", // Now we can send the name
        }),
      },
      // Optional: Add a visual notification as well
      notification: {
        title: "Call Cancelled",
        body: `${callerData.name || "Someone"} cancelled the call.`,
      }};
    await admin.messaging().send(message);
    await db.collection("calls").doc(callId).update({
      status: "cancelled",
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {success: true};
  } catch (error) {
    console.error("cancelCall Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
