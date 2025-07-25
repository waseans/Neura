// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neura/screens/home_screen.dart';
import 'package:neura/screens/splash_screen.dart';
import 'package:neura/screens/login_screen.dart';
 // Import login screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neura - AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(), // Add login route
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}