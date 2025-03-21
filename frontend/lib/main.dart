import 'package:flutter/material.dart';
import 'package:frontend/screens/authpage.dart';
import 'package:frontend/screens/homepage.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/jwtDecodeService.dart'; 

var URL = 'http://10.0.2.2:8080'; //replace this with ur local ip / lan ip for devices connecting on same lan / server ip if hosted (10.0.2.2:8080) for localhost
var URL2 = 'http://10.0.2.2:5000';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  final jwtService = JwtService();
  bool isLoggedIn = await jwtService.isLoggedIn(); // Checks if JWT is valid

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner!!
      title: 'COOKAiGA',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
          const Color(0xFF80A6A4), // for Flutter, add the HEX Code after 'FF'
        ),
      ),
      home: isLoggedIn ? const HomePage() : const AuthPage(), // Login check
    );
  }
}
