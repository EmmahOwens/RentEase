import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore import
import '../../../core/models/message.dart';
import '../../auth/providers/auth_provider.dart'; // Added AuthProvider import

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider _authProvider; // Inject AuthProvider
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _userId;
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  MessageProvider(this._authProvider) {
    _userId = _authProvider.currentUser?.uid;
    if (_userId != null) {
      _listenToMessages();
    } else {
      _authProvider.addListener(_onAuthStateChanged);
    }
  }

  void _onAuthStateChanged() {
    final newUserId = _authProvider.currentUser?.uid;
    if (newUserId != _userId) {
      _userId = newUserId;
      _messageSubscription?.cancel(); // Cancel previous subscription
      if (_userId != null) {
        _listenToMessages();
      } else {
        _messages = []; // Clear messages on logout
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _listenToMessages() {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    // Listen to messages where the current user is either the sender or receiver
    final query1 = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true);

    final query2 = _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true);

    // Combine streams (simple approach, might need refinement for large datasets or complex merging)
    // A more robust approach might involve separate listeners or backend aggregation.
    _messageSubscription = query1.snapshots().listen((snapshot1) {
      _updateMessagesFromSnapshots(snapshot1, null);
    }, onError: _handleStreamError);

    // Note: Listening to two queries separately and merging might lead to duplicates
    // if not handled carefully. Consider structuring data or queries differently if needed.
    // For simplicity here, we'll merge in the update function, but be aware of potential issues.
    query2.snapshots().listen((snapshot2) {
      _updateMessagesFromSnapshots(null, snapshot2);
    }, onError: _handleStreamError);

    // Initial load might still show loading until both streams emit
  }

  void _updateMessagesFromSnapshots(QuerySnapshot? snapshot1, QuerySnapshot? snapshot2) {
    // Basic merge and deduplication logic
    final combinedMessages = <String, Message>{};

    if (snapshot1 != null) {
      for (var doc in snapshot1.docs) {
        final msg = Message.fromJson(doc.data() as Map<String, dynamic>); // Ensure data is cast
        combinedMessages[msg.id] = msg;
      }
    }
    if (snapshot2 != null) {
      for (var doc in snapshot2.docs) {
        final msg = Message.fromJson(doc.data() as Map<String, dynamic>); // Ensure data is cast
        combinedMessages[msg.id] = msg;
      }
    }

    _messages = combinedMessages.values.toList();
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp

    _isLoading = false;
    notifyListeners();
  }

  void _handleStreamError(error) {
     print("Error listening to messages: $error");
     _isLoading = false;
     notifyListeners();
     // Handle error appropriately
  }


  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    if (_userId == null || senderId != _userId) return; // Ensure sender is the logged-in user

    final messageId = const Uuid().v4();
    final message = Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false, // Default to unread
    );

    try {
      await _firestore.collection('messages').doc(messageId).set(message.toJson());
      // No need to manually add, listener will update
    } catch (e) {
      print("Error sending message: $e");
      // Handle error (e.g., show message to user)
    }
  }

  Future<void> deleteMessage(String messageId) async {
     if (_userId == null) return;
    try {
      // Optional: Add security rule to ensure only sender/receiver can delete
      await _firestore.collection('messages').doc(messageId).delete();
      // No need to manually remove, listener will update
    } catch (e) {
      print("Error deleting message: $e");
      // Handle error
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (_userId == null) return;
    try {
      // Optional: Add security rule to ensure only sender can edit
      await _firestore.collection('messages').doc(messageId).update({'content': newContent});
      // No need to manually update, listener will update
    } catch (e) {
      print("Error editing message: $e");
      // Handle error
    }
  }

  // Methods below operate on the locally synced list

  List<Message> getMessagesForUser(String userId) {
    // This operates on the locally synced list, already filtered by the listener
    return _messages;
  }

  List<Message> getConversation(String user1Id, String user2Id) {
    // Filter the locally synced list for the specific conversation
    return _messages
        .where((m) =>
            (m.senderId == user1Id && m.receiverId == user2Id) ||
            (m.senderId == user2Id && m.receiverId == user1Id))
        .toList();
  }

  Future<void> markMessageAsRead(String messageId) async {
    if (_userId == null) return;
    try {
      // Optional: Add security rule to ensure only receiver can mark as read
      await _firestore.collection('messages').doc(messageId).update({'isRead': true});
      // No need to manually update, listener will update
    } catch (e) {
      print("Error marking message as read: $e");
      // Handle error
    }
  }

  int getUnreadCount(String userId) {
    // Operates on the locally synced list
    return _messages
        .where((m) => m.receiverId == userId && !m.isRead)
        .length;
  }
}