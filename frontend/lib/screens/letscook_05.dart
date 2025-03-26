import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen.dart';
import 'package:frontend/screens/letscook_06.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:frontend/screens/recipe_screen.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';
import 'letscook_03.dart';
import 'letscook_06.dart';

class LetsCook05Content extends StatelessWidget {
  final Function(bool isCookingAlone) onModeSelected;

  const LetsCook05Content({Key? key, required this.onModeSelected}) : super(key: key);

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
                        .push(fadeTransition(const LetsCook03Content()));
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
                  "Who are you \ncooking with?",
                  style: textHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => onModeSelected(false),
                  child: canvaImage('cooking_with_parent.png',
                      width: 200, height: 200),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () => onModeSelected(true),
                  child: canvaImage('cooking_alone.png',
                      width: 200, height: 200),
                ),
                // canvaImage('browse_recipes.png', width: 150, height: 150),
                // const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
