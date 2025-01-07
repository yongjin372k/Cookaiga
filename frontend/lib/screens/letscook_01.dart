import 'package:flutter/material.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';
import 'letscook_03.dart';

class LetsCook01Content extends StatelessWidget {
  const LetsCook01Content({super.key});

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
                  "Let's cook up \nsomething special!",
                  style: textHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadeTransition(const LetsCook03Content()));
                  },
                  child: canvaImage('scan_ingredients.png',
                      width: 150, height: 150),
                ),
                const SizedBox(height: 1),
                canvaImage('browse_recipes.png', width: 150, height: 150),
                const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
