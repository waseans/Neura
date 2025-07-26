import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/welcome/ui/welcome_page.dart';
import 'features/home/ui/home_page.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/signup_page.dart';
import 'theme/app_theme.dart';
import 'features/device/device_auth.dart';

void main() {
  runApp(const ProviderScope(child: VoiceAssistantApp()));
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PersonaFlex',
      debugShowCheckedModeBanner: false,

      // Light theme (not used, but required for fallback)
      theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.deepPurple,
      ),
      useMaterial3: true,
    ),

      // Dark theme from theme/app_theme.dart
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.dark, // Force dark mode for now

      // Routing
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/device-auth': (context) => const DeviceAuthPage(),
        // TODO: Add additional routes here
      },
    );
  }
}
