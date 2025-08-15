# --- ProGuard/R8 rules for Flutter, Firebase, ZegoCloud, Stripe, and other common Flutter packages ---

# Keep Flutter-specific classes.
# These are essential for the Flutter engine and plugins to work correctly.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- Rules for Google Play Core library ---
# CRITICAL for apps using App Bundles, Dynamic Delivery, or certain Flutter features
# that interact with Google Play Services. These classes are often aggressively removed by R8.
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.** { *; }

# --- Firebase Core Rules ---
# Essential for Firebase initialization and basic functionality.
-keep class com.google.firebase.** { *; }

# --- Firebase Authentication Rules ---
# Rules specific to Firebase Authentication.
-keep class com.google.firebase.auth.** { *; }

# --- Cloud Firestore Rules ---
# Rules for Firestore data persistence and queries.
-keep class com.google.firebase.firestore.** { *; }
# Keep your data models (Entities/Models) from being obfuscated,
# especially if they are used with Firestore converters or serialization.
# Replace 'com.example.health_connect' with your actual Java package name (e.g., in AndroidManifest.xml)
-keep class com.example.health_connect.features.** { *; } # Adjust this package name if different

# --- Firebase Cloud Functions Rules ---
# If you are using callable Cloud Functions from Flutter.
-keep class com.google.firebase.functions.** { *; }

# --- Firebase Storage Rules ---
# If you are using Firebase Storage for file uploads/downloads.
-keep class com.google.firebase.storage.** { *; }

# --- Firebase Messaging (FCM) Rules ---
# Essential for receiving push notifications.
-keep class com.google.firebase.messaging.** { *; }

# --- Firebase App Check Rules ---
# If you are using Firebase App Check for security.
-keep class com.google.firebase.appcheck.** { *; }

# --- Stripe Rules (from your provided rules, expanded for common Stripe usage) ---
# Keep all Stripe-related classes to prevent runtime issues with payment flows.
-keep class com.stripe.** { *; }
-keep class com.stripe.android.** { *; }
-keep class com.stripe.stripeterminal.** { *; } # If using Stripe Terminal
-keep class com.stripe.android.pushProvisioning.** { *; } # Your existing rules
-dontwarn com.stripe.android.pushProvisioning.** # Your existing rules

# --- ZegoCloud Express Engine Rules ---
# CRITICAL for Zego's real-time communication functionality.
# These native libraries are large and must not be stripped.
-keep class **.zego.** { *; }
-keep class im.zego.** { *; }

# --- ZegoCloud UI Kit Rules (if using zego_uikit_prebuilt_call) ---
# If you are using the prebuilt UI kit for calls.
-keep class com.zego.zego_uikit_prebuilt_call.** { *; }
-keep class com.zego.uikit.prebuilt.call.** { *; }
-keep class com.zego.uikit.plugin.** { *; }
-keep class com.zego.uikit.service.** { *; }

# --- ZegoCloud ZIMKit Rules (if using zego_zimkit for chat) ---
# If you are using ZIMKit for instant messaging.
-keep class im.zego.zim.** { *; }
-keep class im.zego.zim_flutter.** { *; }

# --- PDFx Rules ---
# If you are using pdfx for PDF viewing.
-keep class com.rizing.pdfx.** { *; }

# --- Image Picker Rules ---
# If you are using image_picker.
-keep class com.mr.flutter.plugin.imagepicker.** { *; }

# --- URL Launcher Rules ---
# If you are using url_launcher.
-keep class io.flutter.plugins.urllauncher.** { *; }

# --- Permission Handler Rules ---
# If you are using permission_handler.
-keep class com.baseflow.permissionhandler.** { *; }

# --- General Google Play Services Rules ---
# Often needed for various Google services.
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.finsky.external.client.api.** { *; }
-keepnames class com.google.android.gms.tasks.Task
-keepnames class com.google.android.gms.tasks.OnSuccessListener
-keepnames class com.google.android.gms.tasks.OnFailureListener

# --- Other common Flutter plugins that might need rules ---
# If you encounter issues with other plugins, you might need to add their specific rules here.
# For example, for shared_preferences, cached_network_image, etc., though they often don't need explicit rules.

# --- Suppress Warnings (Optional but Recommended for known issues) ---
# These prevent build warnings for known issues in certain SDKs/libraries.
-dontwarn im.zego.**
-dontwarn com.zego.**
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
-dontwarn okhttp3.**
-dontwarn org.conscrypt.**
-dontwarn org.apache.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.Unsafe
-dontwarn kotlin.Metadata
