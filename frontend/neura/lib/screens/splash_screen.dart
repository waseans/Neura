// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For checking login status

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _checkLoginStatusAndNavigate();
  }

  _checkLoginStatusAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash screen duration
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        // User is already logged in, go to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Not logged in, go to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB), // Deep purple
              Color(0xFF2575FC), // Bright blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Neura',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Intelligent Edge Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 100),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Initializing AI...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}