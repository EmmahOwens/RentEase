import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/airbnb_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/auth_wrapper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/messages/providers/message_provider.dart';

class PreferencesService {
  static Future<void> init() async {
    await SharedPreferences.getInstance();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),
        ChangeNotifierProvider<MessageProvider>(
          create: (_) => MessageProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'RentEase',
            debugShowCheckedModeBanner: false,
            theme: AirbnbTheme.getLightTheme(),
            darkTheme: AirbnbTheme.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}