import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/airbnb_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/auth_wrapper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/messages/providers/message_provider.dart';
import 'package:firebase_core/firebase_core.dart';

class PreferencesService {
  static Future<void> init() async {
    await SharedPreferences.getInstance();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyBwF8-9mbK8gMQX8sbUG5P4O76AXEDp06M",
        authDomain: "rentease256.firebaseapp.com",
        appId: "1:910794508112:web:50bb74bc1af3f1c7270e55",
        messagingSenderId: "910794508112",
        projectId: "rentease256"
    ));
  } else {
    // Initialize SharedPreferences
    await PreferencesService.init();

    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Error initializing Firebase: $e");
    }
  }

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