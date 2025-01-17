import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'package:frontend/screens/community_screen.dart'; // Import CommunityPage
import 'package:frontend/screens/rewards.dart'; // Import StickerCollectionPage
import 'design.dart';
import 'letscook_01.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          createMaterialColor(const Color(0xFF000000)), // Outer background
      body: const Center(
        child: HomePageContent(),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<int> _userPoints; // Future to store user points

  @override
  void initState() {
    super.initState();
    _userPoints = _fetchUserPoints(); // Initialize the future
  }

  // Function to fetch user points from the backend
  Future<int> _fetchUserPoints() async {
    const int userID = 1; // Replace with the actual user ID
    final String apiUrl = "$URL/api/users/$userID";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['points']; // Assuming the response contains a `points` field
      } else {
        print("Failed to fetch user points. Status Code: ${response.statusCode}");
        return 0; // Default to 0 on failure
      }
    } catch (e) {
      print("Error fetching user points: $e");
      return 0; // Default to 0 on exception
    }
  }

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
                GestureDetector(
                  onTap: () {
                    // Navigate to StickerCollectionPage when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StickerCollectionPage()),
                    );
                  },
                  child: Container(
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
                        const SizedBox(width: 8), // Add spacing between coin and text

                        // Dynamic Points Display
                        FutureBuilder<int>(
                          future: _userPoints,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                '...',
                                style: textBody, // Display loading indicator
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Error',
                                style: textBody, // Display error message
                              );
                            } else {
                              return Text(
                                '${snapshot.data}', // Display fetched points
                                style: textBody,
                              );
                            }
                          },
                        ),
                      ],
                    ),
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
