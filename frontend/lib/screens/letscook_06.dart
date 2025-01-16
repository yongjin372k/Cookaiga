import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen.dart';
import 'package:frontend/screens/recipe_screen.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';
import 'letscook_03.dart';
import 'letscook_05.dart';

class LetsCook06Content extends StatelessWidget {
  const LetsCook06Content({Key? key, required this.onNext}) : super(key: key);
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          createMaterialColor(const Color(0xFF80A6A4)), // Background color
      body: Stack(
        children: [
          // Row for Top-Left and Top-Right Images
          // Positioned(
          //   top: 10, // Adjust vertical position
          //   left: 10, // Adjust left margin
          //   right: 10, // Adjust right margin
          //   child: Row(
          //     mainAxisAlignment:
          //         MainAxisAlignment.spaceBetween, // Space between the two items
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).push(
          //             fadeTransition(
          //               LetsCook05Content(
          //                 onNext: () {
          //                   // Define what should happen when 'onNext' is called
          //                   Navigator.of(context).pop(); // Example action
          //                 },
          //               ),
          //             ),
          //           );
          //         },
          //         child: canvaImage('back_arrow.png', width: 50, height: 50),
          //       ),
          //     ],
          //   ),
          // ),

          // Main Content at the Center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Instructions: ",
                  style: textHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                canvaImage('instructions_child.png', width: 150, height: 150),
                const SizedBox(height: 10),
                canvaImage('instructions_parent.png', width: 150, height: 150),
                const SizedBox(height: 10),
                canvaImage('instructions_everyone.png', width: 150, height: 150),
              ],
            ),
          ),

          // Button at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF336A84),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Text(
                  "let's cook",
                  style: textBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
