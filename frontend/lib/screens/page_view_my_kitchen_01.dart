import 'dart:math';
import 'package:flutter/material.dart';
import 'page_home.dart';
import 'page_view_my_kitchen_02.dart';
import 'page_view_my_kitchen_04.dart';
import '../controller/audio_controller.dart';

final double imageSizeOfButton = 180.0;
final double dynamicVerticalPadding = imageSizeOfButton * 0.05;

class ViewMyKitchen01 extends StatelessWidget {
  const ViewMyKitchen01({Key? key}) : super(key: key);
  
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

          // Safe Area for UI Elements
          SafeArea(
            child: Column(
              children: [
                // -- START of back button to Homepage. --
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40 * 0.05),
                        child: RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => HomePage()),
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
                      ),
                    ],
                  ),
                ),
                // -- END of back button to Homepage. --

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

                // -- START of action buttons inside the body. --
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      if (isMusicOn) {
                        toggleMusic(); // Stop music before navigating
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ViewMyKitchen02()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/scan_grocery.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                // Browse Recipes Button.
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ViewMyKitchen04()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/browse_inventory.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
                // -- END of action buttons. --
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
