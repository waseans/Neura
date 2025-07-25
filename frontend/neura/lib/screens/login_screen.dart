// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // IMPORTANT: Replace with your Django backend URL
  // For Android Emulator: http://10.0.2.2:8000
  // For iOS Simulator: http://localhost:8000 (or your machine's local IP)
  // For physical device: http://YOUR_LOCAL_IP_ADDRESS:8000
  final String _djangoBaseUrl = "http://127.0.0.1:8000"; // Adjust as needed
  final Dio _dio = Dio(); // Create a Dio instance

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = '$_djangoBaseUrl/api/users/login/';
    try {
      final response = await _dio.post(
        url,
        data: { // Dio uses `data` for the request body
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data; // Dio automatically decodes JSON
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('username', _usernameController.text); // Store username too

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Dio often throws an error for non-2xx status codes, but if it doesn't,
        // this handles it. `response.data` for error details.
        final errorData = response.data;
        setState(() {
          _errorMessage = errorData['detail'] ?? 'Login failed. Please try again.';
        });
      }
    } on DioException catch (e) { // Catch Dio-specific errors
      setState(() {
        if (e.response != null && e.response!.data != null) {
          _errorMessage = e.response!.data['detail'] ?? 'An error occurred: ${e.message}';
        } else {
          _errorMessage = 'Network error or no response: ${e.message}';
        }
      });
    } catch (e) { // Catch any other unexpected errors
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_open, // Login icon
                  size: 80,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.white54,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Welcome to Neura',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.white.withOpacity(0.7)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.7)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background
                          foregroundColor: const Color(0xFF6A11CB), // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: Implement registration navigation or dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration functionality coming soon!')),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
