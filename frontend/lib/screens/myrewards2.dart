import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/rewards.dart';
import 'design.dart';
import 'homepage.dart';
import 'myrewards3.dart'; // Import MyRewards3Page
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyRewards2Page extends StatefulWidget {
  const MyRewards2Page({super.key});

  @override
  _MyRewards2PageState createState() => _MyRewards2PageState();
}

class _MyRewards2PageState extends State<MyRewards2Page> {
  int _userPoints = 0; // Variable to hold the user's points
  bool _isLoading = true; // Loading state for user points

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // Fetch user points when the page loads
  }

  // Function to fetch user points from the backend
  Future<void> _fetchUserPoints() async {
    const int userID = 1; // Replace with the actual user ID
    final String apiUrl = "$URL/api/users/$userID";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userPoints = data['points']; // Assuming the response contains a `points` field
          _isLoading = false;
        });
      } else {
        print("Failed to fetch user points. Status Code: ${response.statusCode}");
        setState(() {
          _userPoints = 0; // Default to 0 on failure
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user points: $e");
      setState(() {
        _userPoints = 0; // Default to 0 on exception
        _isLoading = false;
      });
    }
  }

  // Helper method to show a dialog when points are insufficient
  void _showInsufficientPointsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog without action
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5B98A9),
          title: const Text(
            "Not Enough Points",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Chewy',
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You need at least 60 points to purchase this sticker.",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Chewy',
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9), // Background color
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button with custom image that navigates to HomePage
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StickerCollectionPage(),
                        ),
                      );
                    },
                    child: canvaImage('back_arrow.png', width: 50, height: 50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Purchase a Sticker Header
            Column(
              children: [
                canvaImage('cart_icon.png', width: 70, height: 70), // Shopping bag image
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 10),
            // Current Coins Display
            Column(
              children: [
                const Text(
                  'You currently have',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF336B89),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      canvaImage('reward_coin.png', width: 25, height: 25),
                      const SizedBox(width: 8),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              '$_userPoints',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Chewy',
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reduced height from 20
            // Question Header
            const Text(
              'Would you like to purchase a\nmysterious sticker?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Chewy',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5), // Reduced height to bring the grid closer
            // Sticker Options (2x2 Non-Scrollable Layout)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10), // Reduced horizontal padding
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two stickers per row
                    mainAxisSpacing: 5, // Adjusted space between rows
                    crossAxisSpacing: 15, // Adjusted space between columns
                    childAspectRatio: 1, // Ensure cells are square-shaped
                  ),
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  children: [
                    _buildStickerOption('common_sticker.png', context, true),
                    _buildStickerOption('legendary_sticker.png', context, false),
                    _buildStickerOption('rare_sticker.png', context, false),
                    _buildStickerOption('special_sticker.png', context, false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a sticker option with the respective image
  Widget _buildStickerOption(
      String imagePath, BuildContext context, bool isCommonSticker) {
    return GestureDetector(
      onTap: () {
        if (isCommonSticker) {
          if (_userPoints >= 60) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRewards3Page()),
            );
          } else {
            _showInsufficientPointsDialog();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchasing sticker from $imagePath!')),
          );
        }
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent, // Remove background color
        radius: 55, // Slightly reduced size for better spacing
        child: canvaImage(imagePath, width: 120, height: 120), // Sticker image
      ),
    );
  }
}
