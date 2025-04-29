import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/dashboard/screens/tenant_dashboard.dart'; // Assuming TenantDashboard for now
// import '../../features/dashboard/screens/landlord_dashboard.dart'; // Import if needed later

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Listen to auth state changes
    if (authProvider.isAuthenticated) {
      // User is logged in, navigate to the main dashboard
      // TODO: Add logic to differentiate between tenant and landlord dashboards if needed
      return const TenantDashboard(); 
    } else {
      // User is not logged in, show the welcome/login screen
      return const WelcomeScreen();
    }
  }
}