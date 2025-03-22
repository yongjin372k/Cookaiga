import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/homepage.dart';
import 'package:frontend/screens/jwtDecodeService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/main.dart';

class AuthPage extends StatefulWidget {           // Login and Register Page
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true; // Toggle between login and register
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final JwtService _jwtService = JwtService(); // JWT Service for storing tokens

  // Function to Handle Authentication
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent spaces in passwords
    if (passwordController.text.contains(" ")) {
      _showMessage("Password cannot contain spaces.");
      return;
    }

    setState(() => _isLoading = true);
    final String endpoint = isLogin ? "/api/users/login" : "/api/users/register";
    final Uri url = Uri.parse('$URL$endpoint');

    final Map<String, String> requestBody = {
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim()
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (isLogin) {
          String token = responseData['token'];
          await _jwtService.storage.write(key: "jwt_token", value: token);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else {
          _showMessage("Registration successful! Please login.");
          setState(() => isLogin = true);
        }
      } else if (response.statusCode == 401) {
        _showMessage("Incorrect username or password. Please try again.");
      } else {
        final responseData = jsonDecode(response.body);
        _showMessage(responseData['message'] ?? "Authentication failed.");
      }
    } catch (e) {
      _showMessage("Network error. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show SnackBar Message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  canvaImage('cookaiga_logo_four.png', width: 120, height: 120),
                  const SizedBox(height: 20),

                  // Page Title
                  Text(
                    isLogin ? "Login to COOKAIGA" : "Register for COOKAIGA",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Chewy',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(usernameController, "Username"),
                        const SizedBox(height: 15),
                        _buildTextField(passwordController, "Password", obscureText: true),
                        if (!isLogin) ...[
                          const SizedBox(height: 15),
                          _buildTextField(confirmPasswordController, "Confirm Password", obscureText: true),
                        ],
                        const SizedBox(height: 25),
                        _buildAuthButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Toggle between Login & Register
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Chewy'),
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

  // Text Field Builder
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "$label cannot be empty";

        if (label == "Password" || label == "Confirm Password") {
          if (value.contains(" ")) {
            return "Password cannot contain spaces";
          }
          if (!isLogin && label == "Confirm Password" && value != passwordController.text) {
            return "Passwords do not match";
          }
        }

        return null;
      },
    );
  }

  // Login/Register Button
  Widget _buildAuthButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAuth, // Disable button while loading
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF336B89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              isLogin ? "Login" : "Register",
              style: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
            ),
    );
  }
}
