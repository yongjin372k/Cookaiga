import 'dart:math';
import 'package:flutter/material.dart';
import '../models/data.dart';
import 'page_home.dart';
import 'page_lets_cook_06.dart';
import 'page_lets_cook_07.dart';
import '../controller/audio_controller.dart';

final double imageSizeOfButton = 180.0;
final double dynamicVerticalPadding = imageSizeOfButton * 0.05;
final double imageSizeOfHeader = 150.0;

class LetsCook05 extends StatelessWidget {
  const LetsCook05({Key? key}) : super(key: key);

  void _showBackConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: const Text(
            "Are you sure?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 20.0, color: Colors.white),
          ),
          content: const Text(
            "Going back will require you to scan ingredients again. Do you want to continue?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "VarelaRound", fontSize: 14.0, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                "Stay Here",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text(
                "Go Back",
                style: TextStyle(fontSize: 16.0, color: Colors.redAccent),
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_lets_cook_01.png', // Ensure the path is correct
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),

          // Safe Area for UI Elements
          SafeArea(
            child: Column(
              children: [
                // -- START of Back Button, Headline, and Music Toggle --
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Arrow with Confirmation Dialog
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40 * 0.05),
                        child: RawMaterialButton(
                          onPressed: () {
                            _showBackConfirmationDialog(context);
                          },
                          fillColor: const Color(0xFF5E92A8),
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          shape: const CircleBorder(),
                          child: Image.asset(
                            'assets/buttons/back_arrow.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),

                      // Music Toggle Button
                      RawMaterialButton(
                        onPressed: () async {
                          await toggleMusic();
                          (context as Element).markNeedsBuild(); // Ensure UI updates
                        },
                        fillColor: const Color(0xFF5E92A8),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        shape: const CircleBorder(),
                        child: Image.asset(
                          isMusicOn ? 'assets/buttons/sound_on_white.png' : 'assets/buttons/sound_off_white.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                // -- END of Back Button, Headline, and Music Toggle --

                const SizedBox(height: 20.0),

                // -- START of headline. --
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const RandomTagline(),
                    ],
                  ),
                ),
                // -- END of headline. --

                const SizedBox(height: 10.0),

                // -- START of Cooking Choice Buttons --
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      navigateToNextStep(
                        context,
                        "Chicken Teriyaki Stir Fry", // Recipe Name
                        chickenTeriyakiSteps, // List of steps
                        0, // Start from Step 1
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/cooking_with_parent.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      // You can start another recipe or change logic here for cooking alone
                      navigateToNextStep(
                        context,
                        "Chicken Teriyaki Stir Fry",
                        chickenTeriyakiSteps,
                        0,
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/cooking_alone.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
                // -- END of Cooking Choice Buttons --
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RandomTagline extends StatefulWidget {
  const RandomTagline({Key? key}) : super(key: key);

  @override
  _RandomTaglineState createState() => _RandomTaglineState();
}

class _RandomTaglineState extends State<RandomTagline> {
  final List<String> taglines = [
    "Who’s joining you \nin the kitchen today?",
    "Cooking is more fun together! \nWho’s with you?",
    "Team up or solo? \nLet’s get cooking!",
    "Who’s your kitchen \nbuddy for this recipe?",
    "Cooking challenge: \nWith a partner or solo?",
    "It’s time to cook! \nWho’s your sous-chef?",
    "Chef or assistant? \nWho's joining you?",
  ];

  late String selectedTagline;

  @override
  void initState() {
    super.initState();
    final random = Random();
    selectedTagline = taglines[random.nextInt(taglines.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      selectedTagline,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Chewy',
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

void navigateToNextStep(BuildContext context, String recipeName, List<Map<String, dynamic>> steps, int currentStep) {
  if (currentStep < steps.length - 1) {
    // Proceed to the next cooking step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LetsCook06(
          recipeName: recipeName,
          stepNumber: currentStep + 1, // Move to the next step
          totalSteps: steps.length,
          stepDescription: steps[currentStep + 1]["description"],
          isChildsTurn: steps[currentStep + 1]["isChildsTurn"],
          onNextStep: () {
            navigateToNextStep(context, recipeName, steps, currentStep + 1);
          },
        ),
      ),
    );
  } else {
    // If it's the last step, update reward coins and navigate to completion page
    int earnedRewards = steps.length * 10; // 10 coins per step
    rewardCoinValue += earnedRewards; // Update global reward variable

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LetsCook07(
          recipeName: recipeName,
          totalSteps: steps.length,
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> chickenTeriyakiSteps = [
  {"description": "Chop the chicken into bite-sized pieces.", "isChildsTurn": true},
  {"description": "Heat the pan and add some oil.", "isChildsTurn": false},
  {"description": "Stir-fry the chicken until golden brown.", "isChildsTurn": true},
  {"description": "Add teriyaki sauce and let it simmer.", "isChildsTurn": false},
  {"description": "Stir occasionally and cook until thickened.", "isChildsTurn": true},
  {"description": "Serve with steamed rice and enjoy!", "isChildsTurn": false},
];

