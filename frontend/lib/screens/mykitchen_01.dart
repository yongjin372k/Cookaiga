import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen_inventory.dart';
import 'package:frontend/screens/mykitchen_03.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';

class MyKitchen01Content extends StatelessWidget {
  const MyKitchen01Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          createMaterialColor(const Color(0xFF80A6A4)), // Background color
      body: Stack(
        children: [
          // Row for Top-Left and Top-Right Images
          Positioned(
            top: 10, // Adjust vertical position
            left: 10, // Adjust left margin
            right: 10, // Adjust right margin
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between the two items
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadeTransition(const HomePage()));
                  },
                  child: canvaImage('back_arrow.png', width: 50, height: 50),
                ),
              ],
            ),
          ),

          // Main Content at the Center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Welcome to \nyour kitchen!",
                  style: textHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadeTransition(CameraPageInventory())); // Navigate to next page
                  },
                  child: canvaImage('scan_grocery.png', width: 150, height: 150),
                ),
                const SizedBox(height: 1),
                // Clickable browse_inventory.png
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadeTransition(MyKitchen03Content())); // Navigate to next page
                  },
                  child: canvaImage('browse_inventory.png', width: 150, height: 150),
                ),
                const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
