import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/dashboard_layout.dart';
import '../../../core/widgets/neu_button.dart';
import '../../../core/widgets/neu_card.dart';
import '../../../core/widgets/neu_text_field.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement profile update logic

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _changePassword() async {
    // TODO: Implement password change logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser!;

    return DashboardLayout(
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeuCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                NeuButton(
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                  },
                  isPrimary: false,
                  child: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_isEditing)
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeuCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NeuTextField(
                          label: 'Full Name',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        NeuTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        NeuTextField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        NeuButton(
                          onPressed: _updateProfile,
                          isLoading: _isLoading,
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Change Password'),
                        onTap: _changePassword,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('Notification Settings'),
                        onTap: () {
                          // TODO: Navigate to notification settings
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('Privacy Settings'),
                        onTap: () {
                          // TODO: Navigate to privacy settings
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NeuButton(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                  },
                  isPrimary: false,
                  child: const Text('Logout'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}