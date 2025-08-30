import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this package

import 'features/welcome/ui/welcome_page.dart';
import 'features/home/ui/home_page.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/signup_page.dart';
import 'theme/app_theme.dart';
import 'features/device/device_auth.dart';
import 'screens/summarization_page.dart'; // Import the new page

void main() async {
  // Load environment variables before running the app.
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: VoiceAssistantApp()));
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A placeholder for your authentication check.
    // Replace this with your actual authentication logic.
    // For example, checking if a user is logged in with Firebase Auth.
    final bool isAuthenticated = true; // Set to true for testing purposes.

    // Determine the initial route based on the authentication status.
    final String initialRoute = isAuthenticated ? '/summarization' : '/welcome';

    return MaterialApp(
      title: 'PersonaFlex',
      debugShowCheckedModeBanner: false,

      // Light theme (not used, but required for fallback)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      // Dark theme from theme/app_theme.dart
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.dark, // Force dark mode for now

      // Routing
      initialRoute: initialRoute,
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/device-auth': (context) => const DeviceAuthPage(),
        // New route for the summarization page
        '/summarization': (context) => const SummarizationPage(),
        // TODO: Add additional routes here
      },
    );
  }
}
