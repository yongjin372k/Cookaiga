import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/homepage.dart';
import 'screens/recipe_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          true, // Change it to 'false' if you want to remove the debug banner at the top right
      title: 'COOKAiGA',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
            Color(0xFF80A6A4) // for Flutter, add the HEX Code after 'FF'
            ),
      ),
      home: const HomePage(),
    );
  }
}
