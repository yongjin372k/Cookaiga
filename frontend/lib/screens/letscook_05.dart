import 'package:flutter/material.dart';
import 'package:frontend/screens/audio_controller.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';
import 'letscook_03.dart';
import 'letscook_06.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LetsCook05Content extends StatelessWidget {
  final Function(bool isCookingAlone) onModeSelected;

  const LetsCook05Content({Key? key, required this.onModeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_lets_cook_01.png', // Ensure the path is correct
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          // Row for Top-Left and Top-Right Images
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RawMaterialButton(  
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LetsCook03Content()),
                      );
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

                  RawMaterialButton(
                    onPressed: () async {
                      await toggleMusic(); // Ensure UI updates when toggled
                    },
                    fillColor: const Color(0xFF4A90A4),
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      isMusicOn ? 'assets/buttons/sound_on_white.png' : 'assets/buttons/sound_off_white.png',
                      width: 25,
                      height: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
              
          // Main Content at the Center

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Who are you \ncooking with?",
                  style: TextStyle(
                    fontSize: 26,
                    // fontWeight: FontWeight.bold,
                    fontFamily: 'Chewy',
                    color: Color.fromRGBO(255, 255, 255, 1),
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      if (isMusicOn) toggleMusic();
                      onModeSelected(false); // <-- Your original onTap logic
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: const BoxConstraints.tightFor(
                      width: 150,
                      height: 150,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/cooking_with_parent.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      if (isMusicOn) toggleMusic();
                      onModeSelected(true); // <-- Your original onTap logic
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: const BoxConstraints.tightFor(
                      width: 150,
                      height: 150,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/cooking_alone.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                // canvaImage('browse_recipes.png', width: 150, height: 150),
                // const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
