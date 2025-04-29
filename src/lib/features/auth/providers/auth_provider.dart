import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  static const String _userKey = 'user_data';
  static const String _usersKey = 'users';
  late SharedPreferences _prefs;
  User? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;

  AuthProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _status = AuthStatus.loading;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    final userData = _prefs.getString(_userKey);
    
    if (userData != null) {
      _currentUser = User.fromJson(json.decode(userData));
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  Future<Map<String, dynamic>> _getUsers() async {
    final usersData = _prefs.getString(_usersKey);
    if (usersData != null) {
      return json.decode(usersData) as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    await _prefs.setString(_usersKey, json.encode(users));
  }

  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // In a real app, this would be an API call
      final users = await _getUsers();
      final user = users.values.cast<Map<String, dynamic>>().firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      _currentUser = User.fromJson(user);
      await _prefs.setString(_userKey, json.encode(user));
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? adminCode,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // In a real app, validate admin code with backend
      if (role == 'landlord' && (adminCode == null || adminCode != '123456')) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final users = await _getUsers();
      
      // Check if email already exists
      if (users.values.any((u) => (u as Map<String, dynamic>)['email'] == email)) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final userId = const Uuid().v4();
      final newUser = User(
        id: userId,
        email: email,
        name: name,
        role: role,
        isVerified: false,
      );

      users[userId] = {
        ...newUser.toJson(),
        'password': password,
      };

      await _saveUsers(users);
      _currentUser = newUser;
      await _prefs.setString(_userKey, json.encode(newUser.toJson()));
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_userKey);
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      final users = await _getUsers();
      final userEntry = users.entries.firstWhere(
        (entry) => (entry.value as Map<String, dynamic>)['email'] == email,
        orElse: () => MapEntry('', {}),
      );

      if (userEntry.value.isEmpty) {
        return false;
      }

      // In a real app, send password reset email
      return true;
    } catch (e) {
      return false;
    }
  }
=======
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
>>>>>>> 5964a33 (This might be the time I actually deploy this to Firebase.)
}