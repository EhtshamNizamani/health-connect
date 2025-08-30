// Import the necessary Firebase modules
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// YEH LINE YAHAN HONI CHAHIYE
const stripe = require("stripe")(functions.config().stripe.secret_key);

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
/**
 * ==================================================================
 * ** NAYA STRIPE PAYMENT FUNCTION (FINAL LINTING FIXES) **
 * ==================================================================
 */
exports.createPayment = europeFunctions.https.onCall(async (data, context) => {
  // 1. Check karein ki user authenticated hai ya nahi
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "This function must be called while authenticated.", // Line todi gayi
    );
  }

  // 2. App se aane wala data (sirf doctor ID)
  const {doctorId} = data;

  if (!doctorId) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function requires a 'doctorId' argument.", // Line todi gayi
    );
  }

  // Production-Ready Approach (Recommended)
  // Hum client se amount trust nahi karenge.
  //  Server par doctor ki fee fetch karenge.
  let amountToChargeInPaisa;
  try {
    const doctorDoc = await db.collection("doctors").doc(doctorId).get();
    if (!doctorDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Doctor not found.");
    }
    // Firestore se fee lein (e.g., 500)
    const fee = doctorDoc.data().consultationFee;
    if (!fee) {
      throw new functions.https.HttpsError(
          "not-found",
          "Consultation fee for this doctor is not set.", // Line todi gayi
      );
    }
    // Stripe ko paise mein convert karein
    amountToChargeInPaisa = fee * 100;
  } catch (error) {
    console.error("Error fetching doctor fee:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Could not verify the doctor's fee.",
    );
  }

  try {
    // 3. Stripe Payment Intent banayein
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountToChargeInPaisa, // Securely fetched amount
      currency: "inr", // Aapki currency (e.g., inr, usd)
      automatic_payment_methods: {
        enabled: true,
      },
      // Metadata mein extra info save kar sakte hain
      metadata: {
        userId: context.auth.uid,
        doctorId: doctorId,
      },
    });

    // 4. Client-side ko 'client_secret' return karein
    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error("Stripe Error:", error);
    throw new functions.https.HttpsError(
        "internal",
        "An error occurred while creating the payment intent.",
    );
  }
});


/**
 * Triggered when a new appointment document is created.
 * Sends a notification to the DOCTOR.
 */
exports.onAppointmentCreated = functions
    .region("europe-west1")
    .firestore.document("appointments/{appointmentId}")
    .onCreate(async (snapshot, context) => {
      // 1. Get the data from the newly created appointment
      const appointmentData = snapshot.data();

      const patientName = appointmentData.patientName;
      const doctorId = appointmentData.doctorId;
      const appointmentTime = appointmentData.appointmentDateTime.toDate();
      // Format the time for the notification body (e.g., "Aug 3 at 10:30 AM")
      const formattedTime = new Intl.DateTimeFormat("en-US", {
        month: "short",
        day: "numeric",
        hour: "numeric",
        minute: "2-digit",
        hour12: true,
      }).format(appointmentTime);

      // 2. Get the Doctor's FCM token from the 'users' collection
      const doctorUserDoc = await db.collection("users").doc(doctorId).get();
      if (!doctorUserDoc.exists) {
        console.error(`Doctor user document not found for ID: ${doctorId}`);
        return;
      }
      const {fcmToken} = doctorUserDoc.data();
      if (!fcmToken) {
        console.log(`Doctor ${doctorId} does not have an FCM token.`);
        return;
      }

      // 3. Construct the notification message
      const message = {
        token: fcmToken,
        notification: {
          title: "New Appointment Request",
          body:
           `You have a new request from ${patientName} for ${formattedTime}.`,
        },
        data: {
          "payload": JSON.stringify({
            "type": "new_appointment",
            "appointmentId": context.params.appointmentId,
          }),
        },
        android: {priority: "high"},
        apns: {payload: {aps: {"content-available": 1}}},
      };

      // 4. Send the notification
      console.
          log(`Sending new appointment notification to doctor: ${doctorId}`);
      await admin.messaging().send(message);
    });

/**
 * Triggered when an appointment document is updated.
 * Sends a notification to the PATIENT if the status has changed.
 */
exports.onAppointmentUpdated = functions
    .region("europe-west1")
    .firestore.document("appointments/{appointmentId}")
    .onUpdate(async (change, context) => {
      // 1. Get the data before and after the update
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // 2. IMPORTANT: Check if the 'status' field actually changed.
      // This prevents sending a notification for any other type of update.
      if (beforeData.status === afterData.status) {
        console.log("Status did not change. No notification will be sent.");
        return;
      }

      const patientId = afterData.patientId;
      const doctorName = afterData.doctorName;
      const newStatus = afterData.status; // e.g., 'confirmed' or 'cancelled'
      // Create a user-friendly message
      let notificationBody = "";
      if (newStatus === "confirmed") {
        notificationBody =
        `Your appointment with ${doctorName} has been confirmed.`;
      } else if (newStatus === "cancelled") {
        notificationBody = `Your appointment with ${doctorName} was cancelled.`;
      } else {
        // Don't send notifications for 'completed' or other statuses
        return;
      }

      // 3. Get the Patient's FCM token
      const patientUserDoc = await db.collection("users").doc(patientId).get();
      if (!patientUserDoc.exists) {
        console.error(`Patient user document not found for ID: ${patientId}`);
        return;
      }
      const {fcmToken} = patientUserDoc.data();
      if (!fcmToken) {
        console.log(`Patient ${patientId} does not have an FCM token.`);
        return;
      }

      // 4. Construct the notification message
      const message = {
        token: fcmToken,
        notification: {
          title: `Appointment ${newStatus.
              charAt(0).toUpperCase() + newStatus.slice(1)}`,
          body: notificationBody,
        },
        data: {
          "payload": JSON.stringify({
            "type": "appointment_status_update",
            "appointmentId": context.params.appointmentId,
          }),
        },
        android: {priority: "high"},
        apns: {payload: {aps: {"content-available": 1}}},
      };

      // 5. Send the notification
      console.log(`Sending status update to patient: ${patientId}`);
      await admin.messaging().send(message);
    });

/**
 * ==================================================================
 *  CLEANS UP EXPIRED PENDING APPOINTMENTS (SCHEDULED FUNCTION)
 * ==================================================================
 * This function runs automatically on a schedule (e.g., every 6 hours).
 * It finds all appointments that are still 'pending' but their time has passed,
 * and updates their status to 'expired'.
 */
exports.cleanupExpiredAppointments = functions
    // Choose the region that is closest to your users
    //  or where your database is.
    .region("europe-west1")
    // Set the schedule. 'every 6 hours' is a good balance.
    // You can also use specific cron job
    //  syntax like '0 4 * * *' for 4 AM every day.
    .pubsub.schedule("every 6 hours")
    .onRun(async (context) => {
      // Get the current time.
      const now = admin.firestore.Timestamp.now();
      console.log(`Running cleanup job at: ${now.toDate()
          .toISOString()}`);

      // 1. Create a query to find all "stale" pending appointments.
      // A stale appointment is one where:
      // - The status is 'pending'
      // - The appointmentDateTime is in the past
      const staleAppointmentsQuery = db.collection("appointments")
          .where("status", "==", "pending")
          .where("appointmentDateTime", "<", now);

      try {
        const querySnapshot = await staleAppointmentsQuery.get();

        if (querySnapshot.empty) {
          console.log("No expired pending appointments found. Job finished.");
          return null; // Exit the function gracefully.
        }

        console
            .log(`Found ${querySnapshot.size} expired appointments to update.`);

        // 2. Use a "Batched Write"
        //  to update all found documents at once.
        // This is much more efficient and
        //  cheaper than updating them one by one.
        const batch = db.batch();

        querySnapshot.forEach((doc) => {
          // For each found document, add an
          //  'update' operation to the batch.
          const docRef = db.collection("appointments").doc(doc.id);
          batch.update(docRef, {status: "expired"});
          // Change status to 'expired'
        });

        // 3. Commit the batch to the database.
        await batch.commit();

        console.log(
            `Successfully updated
            ${querySnapshot.size} appointments to 'expired'.`,
        );
        return null; // Job completed successfully.
      } catch (error) {
        console.error("Error cleaning up expired appointments:", error);
        // Throwing an error here can help with monitoring in Google Cloud.
        throw new Error("Failed to cleanup expired appointments.");
      }
    });
