import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'firestore_service.dart'; // To save the token
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import for FieldValue

// Function to handle messages when the app is in the background or terminated
// Needs to be a top-level function (outside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(); // Already initialized in main.dart usually

  print("Handling a background message: ${message.messageId}");
  // Process the message data here
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permissions for iOS and web
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the initial FCM token
    await _updateToken();

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token Refreshed');
      await _updateToken(token: newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // TODO: Display the notification using a local notification package (e.g., flutter_local_notifications)
      }
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by message: ${message.messageId}');
        // TODO: Handle navigation or data processing based on the message
      }
    });

    // Handle messages when the app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state by message: ${message.messageId}');
      // TODO: Handle navigation or data processing based on the message
    });

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _updateToken({String? token}) async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user == null) {
      print('Cannot update FCM token: User not logged in.');
      return;
    }

    try {
      String? currentToken = token;
      if (currentToken == null) {
        // Use VAPID key for web if not running on native platforms
        currentToken = await _firebaseMessaging.getToken(vapidKey: kIsWeb ? "YOUR_WEB_VAPID_KEY_HERE" : null);
      }

      print('FCM Token: $currentToken');
      // Save the token to Firestore under the user's document
      await _firestoreService.usersCollection.doc(user.uid).update({
        'fcmToken': currentToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('FCM token updated in Firestore for user ${user.uid}');
        } catch (e) {
      print('Error getting/updating FCM token: $e');
    }
  }

  // Optional: Method to delete token on sign out
  Future<void> deleteToken() async {
     User? user = _auth.currentUser;
     if (user != null) {
        try {
           await _firestoreService.usersCollection.doc(user.uid).update({'fcmToken': FieldValue.delete()});
           await _firebaseMessaging.deleteToken();
           print('FCM token deleted.');
        } catch (e) {
           print('Error deleting FCM token: $e');
        }
     }
  }
}