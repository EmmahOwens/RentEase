import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/airbnb_button.dart';
import '../../../core/widgets/airbnb_text_field.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'tenant';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
      adminCode: _selectedRole == 'landlord' ? _adminCodeController.text : null,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create account. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Create account',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to get started',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            AirbnbTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AirbnbTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.email_outlined,
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
            AirbnbTextField(
              label: 'Password',
              hint: 'Create a password',
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'I am a',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AirbnbCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      setState(() => _selectedRole = 'tenant');
                    },
                    border: Border.all(
                      color: _selectedRole == 'tenant'
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onBackground.withOpacity(0.1),
                      width: 2,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 32,
                          color: _selectedRole == 'tenant'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tenant',
                          style: TextStyle(
                            color: _selectedRole == 'tenant'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AirbnbCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      setState(() => _selectedRole = 'landlord');
                    },
                    border: Border.all(
                      color: _selectedRole == 'landlord'
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onBackground.withOpacity(0.1),
                      width: 2,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 32,
                          color: _selectedRole == 'landlord'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Landlord',
                          style: TextStyle(
                            color: _selectedRole == 'landlord'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedRole == 'landlord') ...[
              const SizedBox(height: 24),
              AirbnbTextField(
                label: 'Admin Code',
                hint: 'Enter admin code',
                controller: _adminCodeController,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.vpn_key_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the admin code';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 32),
            AirbnbButton(
              text: 'Create Account',
              onPressed: _signup,
              isLoading: _isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}