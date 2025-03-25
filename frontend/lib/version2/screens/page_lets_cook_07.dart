import 'package:flutter/material.dart';
import 'page_home.dart'; // To navigate back home
import '../models/data.dart'; // Access updated rewardCoinValue

class LetsCook07 extends StatelessWidget {
  final String recipeName;
  final int totalSteps;

  const LetsCook07({
    Key? key,
    required this.recipeName,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_lets_cook_07.png',
              fit: BoxFit.cover,
            ),
          ),

          // Safe Area for UI
          SafeArea(
            child: Center( // Ensures content is centered
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Aligns items to center
                children: [
                  // Celebration Text
                  const Text(
                    "Congratulations!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "You have successfully cooked\n$recipeName!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "VarelaRound",
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 70),

                  // Reward Display
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(
                          'assets/buttons/reward_coin.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "+${totalSteps * 10} Coins Earned!",
                          style: const TextStyle(
                            fontFamily: "Chewy",
                            fontSize: 22.0,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Total Coins: $rewardCoinValue",
                          style: const TextStyle(
                            fontFamily: "VarelaRound",
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80A6A4),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(
                        fontFamily: "Chewy",
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
