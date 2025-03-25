import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  // Stateless widgets means its appearance and properties maintains unchanged throughout its lifetime
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COOKAiGA',
      debugShowCheckedModeBanner: false, // Change to false if you want to hide it
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF80A6A4)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}