import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/messages/providers/message_provider.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
              bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isCurrentUser
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white70, size: 16),
                      onPressed: () async {
                        final newContent = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController(
                              text: message.content,
                            );
                            return AlertDialog(
                              title: const Text('Edit Message'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Enter new message',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(controller.text.trim()),
                                  child: const Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          },
                        );

                        if (newContent != null && newContent.isNotEmpty) {
                          await context
                              .read<MessageProvider>()
                              .editMessage(message.id, newContent);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCurrentUser
                      ? Colors.white.withOpacity(0.7)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}