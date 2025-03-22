import 'dart:convert';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'design.dart';
import 'homepage.dart';
import 'package:frontend/screens/jwtDecodeService.dart';

class LetsCook10Content extends StatelessWidget {
  final String recipeName;
  final int coinsEarned;

  const LetsCook10Content({
    Key? key,
    required this.recipeName,       // Recipe name passed down
    required this.coinsEarned,      // Coins earned (default 20)
  }) : super(key: key);

  // Function to update user points
  Future<void> _updateUserPoints(BuildContext context) async {
    final JwtService _jwtService = JwtService();

    // Retrieve the JWT token and user ID
    String? token = await _jwtService.storage.read(key: "jwt_token");
    Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
    int? userID = decodedToken?['id'];

    if (userID == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in. Please log in again.")),
      );
      return;
    }

    final int pointsToAdd = 20;
    final String apiUrl = "$URL/api/users/$userID/points?points=$pointsToAdd";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("User points updated successfully!");
      } else {
        print("Failed to update user points. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating user points: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call _updateUserPoints when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserPoints(context);
    });

    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF80A6A4)),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  canvaImage(
                    'lets_cook_complete.png',
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You've completed cooking",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Chewy',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "and you've earned",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF336A84),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        canvaImage(
                          'reward_coin.png', // Replace with your coin image
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          coinsEarned.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Chewy',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF336A84),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: const Text(
                      "back to homepage",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Chewy',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
