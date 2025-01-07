import 'package:flutter/material.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'transition.dart';

class LetsCook03Content extends StatelessWidget {
  const LetsCook03Content({super.key});

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
                    Navigator.of(context).push(fadeTransition(
                        const LetsCook01Content())); //TODO: Change to letscook_02
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                  decoration: BoxDecoration(
                    color: createMaterialColor(const Color(0xFF336B89)),
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    children: [
                      // Coin Image
                      // canvaImage('reward_coin.png', width: 20, height: 20),
                      const SizedBox(width: 8),

                      // Wrap the Text widget with Flexible
                      Flexible(
                        child: Text(
                          'Keto Egg Loaf', // Replace with a dynamic value if needed
                          style: textBody,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                  decoration: BoxDecoration(
                    color: createMaterialColor(const Color(0xFF336B89)),
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    children: [
                      // Coin Image
                      // canvaImage('reward_coin.png', width: 20, height: 20),
                      const SizedBox(width: 8),

                      // Wrap the Text widget with Flexible
                      Flexible(
                        child: Text(
                          'Cream Cheese Pancake', // Replace with a dynamic value if needed
                          style: textBody,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                  decoration: BoxDecoration(
                    color: createMaterialColor(const Color(0xFF336B89)),
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    children: [
                      // Coin Image
                      // canvaImage('reward_coin.png', width: 20, height: 20),
                      const SizedBox(width: 8),

                      // Wrap the Text widget with Flexible
                      Flexible(
                        child: Text(
                          'Sunny-Side Up', // Replace with a dynamic value if needed
                          style: textBody,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                  decoration: BoxDecoration(
                    color: createMaterialColor(const Color(0xFF336B89)),
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    children: [
                      // Coin Image
                      // canvaImage('reward_coin.png', width: 20, height: 20),
                      const SizedBox(width: 8),

                      // Wrap the Text widget with Flexible
                      Flexible(
                        child: Text(
                          'Omelette', // Replace with a dynamic value if needed
                          style: textBody,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
