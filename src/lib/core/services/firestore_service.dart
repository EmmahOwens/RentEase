import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a reference to the users collection
  CollectionReference get usersCollection => _db.collection('users');

  // Add a new user document
  Future<void> addUser(String userId, String name, String email, String role) async {
    try {
      await usersCollection.doc(userId).set({
        'uid': userId,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(), // Record creation time
      });
      print('User data added to Firestore for user ID: $userId');
    } catch (e) {
      print('Error adding user data to Firestore: $e');
      // Rethrow or handle the error as needed
      rethrow;
    }
  }

  // --- Add other Firestore operations here as needed ---
  // Example: Get user data
  Future<DocumentSnapshot?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}