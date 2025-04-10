import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/widgets/message_bubble.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/message_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser!;
    // In a real app, we would get the landlord ID from somewhere
    const landlordId = 'landlord123';

    context.read<MessageProvider>().sendMessage(
      senderId: currentUser.id,
      receiverId: landlordId,
      content: content,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser!;
    final messages = context.watch<MessageProvider>();
    final conversation = messages.getMessagesForUser(currentUser.id);

    return DashboardLayout(
      title: 'Messages',
      body: Column(
        children: [
          Expanded(
            child: messages.isLoading
                ? const Center(child: CircularProgressIndicator())
                : conversation.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.message,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          final message = conversation[index];
                          return MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == currentUser.id,
                          );
                        },
                      ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: '',
                    hint: 'Type your message...',
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}