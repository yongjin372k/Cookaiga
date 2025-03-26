import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/screens/camera_screen_inventory.dart';
import 'package:frontend/screens/mykitchen_03.dart';
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';

final double imageSizeOfButton = 180.0;
final double dynamicVerticalPadding = imageSizeOfButton * 0.05;

class MyKitchen01Content extends StatelessWidget {
  const MyKitchen01Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_view_my_kitchen_01.png',
              fit: BoxFit.cover,
            ),
          ),

          // Top and Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const HomePage()),
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
                    ],
                  ),
                ),

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

                // Center Main Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome to \nyour kitchen!",
                      style: textHeader,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeTransition(CameraPageInventory()));
                      },
                      child: canvaImage('scan_grocery.png', width: 150, height: 150),
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeTransition(MyKitchen03Content()));
                      },
                      child: canvaImage('browse_inventory.png', width: 150, height: 150),
                    ),
                  ],
                ),

                const Spacer(),
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
    "Welcome to your kitchen!",
    "Your kitchen, your rules.",
    "Step into your culinary space!",
    "Your kitchen is waiting! \nWhat's on the agenda today?",
    "Where delicious ideas come to life!",
    "Home sweet kitchen! \nReady to create something amazing?",
    "Cooking starts here! \nWhat's the first step?",
    "Your personal kitchen kingdom awaits!",
    "Master your kitchen, \nmaster your meals!",
    "A cozy kitchen, \na world of possibilities!",
    "Every great meal begins \nin your kitchen!",
    "Welcome back, Chef! \nWhat’s your next creation?",
    "Your kitchen is your canvas. \nTime to paint with flavors!",
    "A dash of creativity, a pinch of \nlove—your kitchen magic awaits!",
    "From your kitchen to the \ntable — let’s get cooking!",
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