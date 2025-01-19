import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/homepage.dart';
import 'package:frontend/screens/letscook_05.dart';
import 'package:frontend/screens/rewards.dart';
import 'screens/recipe_screen.dart';
import 'package:frontend/screens/mykitchen_03.dart';
import 'package:frontend/screens/checklist.dart';
var URL = 'http://10.0.2.2:8080'; //replace this with ur local ip / lan ip for devices connecting on same lan / server ip if hosted (10.0.2.2:8080) for localhost
var URL2 = 'http://10.0.2.2:5000';

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
      home: HomePage(),
    );
  }
}
