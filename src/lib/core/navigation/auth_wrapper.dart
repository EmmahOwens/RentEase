import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/welcome_screen.dart';
import 'bottom_nav.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>();

    switch (authState.status) {
      case AuthStatus.authenticated:
        return const AppBottomNavigation();
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}