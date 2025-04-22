import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/widgets/neu_card.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return DashboardLayout(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(
                  'Use dark theme throughout the app',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (user?.role == 'landlord') ...[
            _buildSection(
              context,
              'Admin Code',
              [
                ListTile(
                  title: const Text('Update Admin Code'),
                  subtitle: Text(
                    'Change the admin code for your account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAdminCodeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          _buildSection(
            context,
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Payment Reminders'),
                subtitle: Text(
                  'Receive reminders for upcoming payments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                value: true, // TODO: Implement notification settings
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
              SwitchListTile(
                title: const Text('Payment Confirmations'),
                subtitle: Text(
                  'Receive notifications for successful payments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                value: true, // TODO: Implement notification settings
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
              SwitchListTile(
                title: const Text('Messages'),
                subtitle: Text(
                  'Receive notifications for new messages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                value: true, // TODO: Implement notification settings
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Privacy',
            [
              SwitchListTile(
                title: const Text('Biometric Authentication'),
                subtitle: Text(
                  'Use fingerprint or face ID to secure the app',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                value: false, // TODO: Implement biometric authentication
                onChanged: (value) {
                  // TODO: Update biometric settings
                },
              ),
              ListTile(
                title: const Text('Clear App Data'),
                subtitle: Text(
                  'Delete all locally stored data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement clear data functionality
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                title: const Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        NeuCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showAdminCodeDialog(BuildContext context) {
    final adminCodeController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Admin Code'),
          content: TextField(
            controller: adminCodeController,
            decoration: const InputDecoration(
              labelText: 'New Admin Code',
              hintText: 'Enter new admin code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCode = adminCodeController.text.trim();
                if (newCode.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('settings')
                        .doc('adminCode')
                        .set({'code': newCode});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Admin code updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update admin code: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}