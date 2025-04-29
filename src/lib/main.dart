import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/airbnb_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/navigation/auth_wrapper.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/messages/providers/message_provider.dart';
import 'features/auth/providers/auth_provider.dart'; // Import AuthProvider
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'core/services/firebase_messaging_service.dart'; // Import Messaging Service
import 'firebase_options.dart'; // Import Firebase Options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

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
=======
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Messaging Service (run async, don't await)
  FirebaseMessagingService().initialize(); 
>>>>>>> 5964a33 (This might be the time I actually deploy this to Firebase.)

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
        // AuthProvider needs to be created first so it's available to others
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // Use ChangeNotifierProxyProvider to pass AuthProvider to PaymentProvider
        ChangeNotifierProxyProvider<AuthProvider, PaymentProvider>(
          create: (context) => PaymentProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previousPaymentProvider) =>
              PaymentProvider(authProvider), // Recreate when AuthProvider changes (optional, depends on need)
        ),
        // Use ChangeNotifierProxyProvider to pass AuthProvider to MessageProvider
        ChangeNotifierProxyProvider<AuthProvider, MessageProvider>(
          create: (context) => MessageProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previousMessageProvider) =>
              MessageProvider(authProvider), // Recreate when AuthProvider changes (optional)
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