import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/message.dart';

class MessageProvider with ChangeNotifier {
  static const String _messagesKey = 'messages';
  late SharedPreferences _prefs;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  MessageProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _isLoading = true;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    _loadMessages();

    _isLoading = false;
    notifyListeners();
  }

  void _loadMessages() {
    final messagesData = _prefs.getString(_messagesKey);
    if (messagesData != null) {
      final List<dynamic> decoded = json.decode(messagesData);
      _messages = decoded.map((m) => Message.fromJson(m)).toList();
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  Future<void> _saveMessages() async {
    final encoded = json.encode(_messages.map((m) => m.toJson()).toList());
    await _prefs.setString(_messagesKey, encoded);
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

    _messages.insert(0, message);
    await _saveMessages();
    notifyListeners();
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
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isRead: true);
      await _saveMessages();
      notifyListeners();
    }
  }

  int getUnreadCount(String userId) {
    return _messages
        .where((m) => m.receiverId == userId && !m.isRead)
        .length;
  }
}