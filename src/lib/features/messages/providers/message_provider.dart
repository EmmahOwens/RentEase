import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  MessageProvider() {
    _listenToMessages();
  }

  void _listenToMessages() {
    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      _messages = querySnapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    try {
      await _firestore.collection('messages').doc(message.id).set(message.toJson());
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      // Delete the message from Firestore
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({'content': newContent});
    } catch (e) {
      debugPrint('Error editing message: $e');
    }
  }

  List<Message> getMessagesForUser(String userId) {
    return _messages
        .where((m) => m.senderId == userId || m.receiverId == userId)
        .toList();
  }

  List<Message> getConversation(String user1Id, String user2Id) {
    return _messages
        .where((m) =>
    (m.senderId == user1Id && m.receiverId == user2Id) ||
        (m.senderId == user2Id && m.receiverId == user1Id))
        .toList();
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  int getUnreadCount(String userId) {
    return _messages
        .where((m) => m.receiverId == userId && !m.isRead)
        .length;
  }
}