import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'design.dart';
import 'homepage.dart';

class LetsCook10Content extends StatelessWidget {
  final String recipeName; // Recipe name passed from CookingStepsScreen
  final int coinsEarned; // Coins earned (default 20)

  const LetsCook10Content({
    Key? key,
    required this.recipeName,
    required this.coinsEarned,
  }) : super(key: key);

  Future<List<Map<String, String>>> fetchSteps(String recipeName, String ingredients) async {
    try {
      final url = Uri.parse('http://10.0.2.2:5000/generate-recipe-steps');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipe_name': recipeName,
          'ingredients': ingredients.split('\n'),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, String>> steps = (data['steps'] as List<dynamic>)
            .map((step) => {
                  'motivation': (step['motivation'] ?? "").toString(),
                  'step': (step['step'] ?? "").toString(),
                })
            .toList();
        return steps;
      } else {
        throw Exception('Failed to fetch steps: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching steps: $error');
      throw Exception('Could not fetch steps. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          builder: (context) => const HomePage(), // Back to homepage
                        ),
                        (route) => false, // Remove all previous routes
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
