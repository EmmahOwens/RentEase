import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../../../core/services/firestore_service.dart'; // Import FirestoreService
import '../../../core/widgets/airbnb_text_field.dart';
import '../../../core/widgets/airbnb_card.dart';

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

    // Add validation for admin code if landlord is selected
    if (_selectedRole == 'landlord' && _adminCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the admin code for landlord registration.')),
      );
      return;
    }
    // TODO: Add actual validation for the admin code against a secure source

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    try {
      final userCredential = await authProvider.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (userCredential == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed. Please try again.')),
        );
      } else {
        // Save additional user details to Firestore
        final firestoreService = FirestoreService();
        try {
          await firestoreService.addUser(
            userCredential.user!.uid,
            _nameController.text.trim(),
            _emailController.text.trim(),
            _selectedRole,
          );
          print('Signup successful and user data saved!');
          // Navigation is handled by AuthWrapper
        } catch (firestoreError) {
          print('Error saving user data to Firestore: $firestoreError');
          // Optionally: Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful, but failed to save user details.')),
          );
          // Even if Firestore fails, the user is created in Auth, so AuthWrapper will navigate.
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during signup: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to get started',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
            ), // End AirbnbTextField for Password
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
                          : theme.colorScheme.onSurface.withOpacity(0.1),
                      width: 2,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 32,
                          color: _selectedRole == 'tenant'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tenant',
                          style: TextStyle(
                            color: _selectedRole == 'tenant'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
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
                          : theme.colorScheme.onSurface.withOpacity(0.1),
                      width: 2,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 32,
                          color: _selectedRole == 'landlord'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Landlord',
                          style: TextStyle(
                            color: _selectedRole == 'landlord'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: child,
                );
              },
              child: _selectedRole == 'landlord'
                  ? Column(
                      key: const ValueKey('admin_code'), // Add key for AnimatedSwitcher
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        AirbnbTextField(
                          label: 'Admin Code',
                          hint: 'Enter landlord admin code',
                          controller: _adminCodeController,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.admin_panel_settings_outlined,
                          validator: (value) {
                            // Validation is handled in _signup for now
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey('no_admin_code')), // Add key
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signup,
                        child: const Text('Create Account'),
                      ),
                    ),
            ),
          ],
        ),
    )
    );
  }
}