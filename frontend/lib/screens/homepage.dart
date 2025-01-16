import 'package:flutter/material.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'package:frontend/screens/community_screen.dart'; // Import CommunityPage
import 'design.dart';
import 'letscook_01.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          createMaterialColor(const Color(0xFF000000)), // Outer background
      body: Center(
        child: const HomePageContent(),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          createMaterialColor(const Color(0xFF80A6A4)), // Background color
      body: Stack(
        children: [
          Positioned(
            top: 20, // Adjust vertical position
            left: 10, // Adjust left margin
            right: 10, // Adjust right margin
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between the two items
              children: [
                canvaImage('menu_button.png', width: 50, height: 50),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: createMaterialColor(const Color(0xFF336B89)),
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    children: [
                      // Coin Image
                      canvaImage('reward_coin.png', width: 20, height: 20),
                      const SizedBox(
                          width: 8), // Add spacing between coin and text
                      Text(
                        '999', // Replace with a dynamic value if needed
                        style: textBody,
                      ),
                    ],
                  ),
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
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LetsCook01Content()),
                    );
                  },
                  child: canvaImage('lets_cook.png', width: 140, height: 140),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyKitchen01Content()),
                    );
                  },
                  child: canvaImage('view_my_kitchen.png',
                      width: 140, height: 140),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CommunityPage()),
                    );
                  },
                  child: canvaImage('hello_my_community.png',
                      width: 140, height: 140),
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
