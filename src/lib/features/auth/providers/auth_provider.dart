import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_messaging_service.dart'; // Import Messaging Service

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userRole; // Add field to store user role

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _onAuthStateChanged(_auth.currentUser); // Initial check
  }

  User? get currentUser => _user;
  String? get userRole => _userRole; // Add getter for user role

  bool get isAuthenticated => _user != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      try {
        // Force refresh to get latest claims
        IdTokenResult tokenResult = await user.getIdTokenResult(true);
        _userRole = tokenResult.claims?['role'] as String?;
      } catch (e) {
        print('Error fetching custom claims: $e');
        _userRole = null; // Reset role on error
      }
    } else {
      _userRole = null; // Clear role when logged out
    }
    notifyListeners();
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _onAuthStateChanged(userCredential.user); // Fetch claims on sign in
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., invalid email, wrong password)
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optionally: Send verification email, save user data to Firestore, etc.
      // Note: Custom claims are typically set server-side after sign-up.
      // We might need to call _onAuthStateChanged again after claims are set.
      await _onAuthStateChanged(userCredential.user); // Fetch initial state (likely no claims yet)
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., email already in use)
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    // Delete FCM token before signing out
    await FirebaseMessagingService().deleteToken();
    await _auth.signOut();
    // _onAuthStateChanged will be called automatically by the listener
  }
}