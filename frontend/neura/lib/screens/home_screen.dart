// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _connectionStatus = 'Checking...';
  String? _username;
  bool _isLoading = false;

  // IMPORTANT: Replace with your Django backend URL
  final String _djangoBaseUrl = "http://127.0.0.1:8000"; // Adjust as needed
  final Dio _dio = Dio(); // Create a Dio instance

  @override
  void initState() {
    super.initState();
    _loadUserDataAndCheckDeviceStatus();
  }

  Future<void> _loadUserDataAndCheckDeviceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
    _checkDeviceStatus();
  }

  Future<void> _checkDeviceStatus() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      setState(() {
        _connectionStatus = 'Not logged in';
        _isLoading = false;
      });
      return;
    }

    final url = '$_djangoBaseUrl/api/device/status/';
    try {
      final response = await _dio.get( // Changed from http.get to _dio.get
        url,
        options: Options( // Headers are now in Options
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data; // Dio automatically decodes JSON
        setState(() {
          _connectionStatus = data['status'];
        });
      } else {
        // Dio often throws an error for non-2xx status codes, but if it doesn't,
        // this handles it. `response.data` for error details.
        final errorData = response.data;
        setState(() {
          _connectionStatus = errorData['detail'] ?? 'Error checking status';
        });
      }
    } on DioException catch (e) { // Catch Dio-specific errors
      setState(() {
        if (e.response != null && e.response!.data != null) {
          _connectionStatus = e.response!.data['detail'] ?? 'Network error: ${e.message}';
        } else {
          _connectionStatus = 'Network error: ${e.message}';
        }
      });
    } catch (e) { // Catch any other unexpected errors
      setState(() {
        _connectionStatus = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectDevice() async {
    final TextEditingController deviceIdController = TextEditingController();
    final TextEditingController activationCodeController = TextEditingController();

    // Show a dialog to get device ID and activation code
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect NURA Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(labelText: 'Device ID (e.g., mock_nura_001)'),
            ),
            TextField(
              controller: activationCodeController,
              decoration: const InputDecoration(labelText: 'Activation Code (e.g., 12345)'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              setState(() {
                _isLoading = true;
              });
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token');

              if (token == null) {
                _showSnackBar('Not logged in. Please log in first.');
                setState(() { _isLoading = false; });
                return;
              }

              final url = '$_djangoBaseUrl/api/device/connect/';
              try {
                final response = await _dio.post( // Changed from http.post to _dio.post
                  url,
                  options: Options( // Headers are now in Options
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Token $token',
                    },
                  ),
                  data: { // Body is now in `data` parameter
                    'device_id': deviceIdController.text,
                    'activation_code': activationCodeController.text,
                  },
                );

                if (response.statusCode == 200) {
                  _showSnackBar('Device connected successfully!');
                  _checkDeviceStatus(); // Refresh status
                } else {
                  final errorData = response.data;
                  _showSnackBar(errorData['detail'] ?? 'Failed to connect device.');
                }
              } on DioException catch (e) { // Catch Dio-specific errors
                _showSnackBar('An error occurred during connection: ${e.response?.data['detail'] ?? e.message}');
              } catch (e) {
                _showSnackBar('An unexpected error occurred during connection: $e');
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NURA Home'),
        backgroundColor: const Color(0xFF6A11CB), // Matching app bar color
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkDeviceStatus,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              await prefs.remove('username');
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2575FC), // Bright blue
              Color(0xFF6A11CB), // Deep purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, ${_username ?? 'User'}!',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NURA Device Status: $_connectionStatus',
                      style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 40),
                    if (_connectionStatus != 'connected')
                      ElevatedButton.icon(
                        onPressed: _connectDevice,
                        icon: const Icon(Icons.link),
                        label: const Text('Connect NURA Device'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_connectionStatus == 'connected')
                      const Text(
                        'Your NURA device is ready!',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
