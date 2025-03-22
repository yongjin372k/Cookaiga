import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/rewards.dart';
import 'package:frontend/screens/jwtDecodeService.dart'; // Import JWT Service
import 'design.dart';
import 'homepage.dart';
import 'myrewards3.dart';
import 'package:http/http.dart' as http;

class MyRewards2Page extends StatefulWidget {
  const MyRewards2Page({super.key});

  @override
  _MyRewards2PageState createState() => _MyRewards2PageState();
}

class _MyRewards2PageState extends State<MyRewards2Page> {
  int _userPoints = 0; // User's points
  bool _isLoading = true; // Loading state
  final JwtService _jwtService = JwtService(); // JWT Service instance

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  // Fetch user points from backend
  Future<void> _fetchUserPoints() async {

    // Retrieve the JWT token and user ID
    String? token = await _jwtService.storage.read(key: "jwt_token");
    Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
    int? userID = decodedToken?['id'];

    if (userID == null || token == null) {
      print("User authentication failed.");
      setState(() => _isLoading = false);
      return;
    }

    final String apiUrl = "$URL/api/users/$userID";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userPoints = data['points'] ?? 0;
          _isLoading = false;
        });
      } else {
        print("Failed to fetch user points. Status Code: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching user points: $e");
      setState(() => _isLoading = false);
    }
  }

  // Show insufficient points dialog
  void _showInsufficientPointsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5B98A9),
          title: const Text(
            "Not Enough Points",
            style: TextStyle(color: Colors.white, fontFamily: 'Chewy', fontSize: 24),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You need at least 60 points to purchase this sticker.",
            style: TextStyle(color: Colors.white, fontFamily: 'Chewy', fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("OK", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy')),
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
      backgroundColor: const Color(0xFF5B98A9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StickerCollectionPage()),
                      );
                    },
                    child: canvaImage('back_arrow.png', width: 50, height: 50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Purchase Header
            Column(
              children: [
                canvaImage('cart_icon.png', width: 70, height: 70),
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 10),

            // Current Coins Display
            Column(
              children: [
                const Text(
                  'You currently have',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
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
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                              '$_userPoints',
                              style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Chewy'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Question Header
            const Text(
              'Would you like to purchase a\nmysterious sticker?',
              style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),

            // Sticker Options Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
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

  // Sticker Option Widget
  Widget _buildStickerOption(String imagePath, BuildContext context, bool isCommonSticker) {
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
        backgroundColor: Colors.transparent,
        radius: 55,
        child: canvaImage(imagePath, width: 120, height: 120),
      ),
    );
  }
}
