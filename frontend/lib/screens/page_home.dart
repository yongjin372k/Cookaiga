import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/data.dart';
import 'page_lets_cook_01.dart';
import 'page_view_my_kitchen_01.dart';
import 'hello_my_community_01.dart';
import '../controller/audio_controller.dart';
import 'page_user_profile.dart';

final double imageSizeOfButton = 180.0;
final double dynamicVerticalPadding = imageSizeOfButton * 0.05;
final double imageSizeOfButtonSettings = 140.0;
final double dynamicVerticalPaddingSettings = imageSizeOfButtonSettings * 0.05;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    playMusic().then((_) { // Start the music on HomePage load.
      setState(() {
        isMusicOn = true; // Ensure UI updates correctly
      });
    });
  }
  
  @override
  void dispose() {
    globalAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_home.png',
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),

          // Safe Area to prevent UI overlap with notches
          SafeArea(
            child: Column(
              children: [
                // -- START of the menu button & reward coin display at the top bar. --
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Settings and Music toggle buttons side by side
                      Row(
                        children: [
                          // Menu Button
                          RawMaterialButton(
                            onPressed: () {
                              showSettingsDialog(context);
                            },
                            fillColor: const Color(0xFF5E92A8),
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 40,
                            ),
                            shape: const CircleBorder(),
                            child: Image.asset(
                              'assets/buttons/menu_settings_3.png',
                              width: 35,
                              height: 35,
                            ),
                          ),

                          const SizedBox(width: 10), // Add spacing between buttons

                          // Music Toggle Button
                          RawMaterialButton(
                            onPressed: () async {
                              await toggleMusic();
                              setState(() {}); // Update UI when music is toggled
                            },
                            fillColor: const Color(0xFF5E92A8),
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 40,
                            ),
                            shape: const CircleBorder(),
                            child: Image.asset(
                              isMusicOn ? 'assets/buttons/sound_on.png' : 'assets/buttons/sound_off.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ],
                      ),

                      // Reward coin display.
                      InkWell(
                        onTap: () {
                          // TODO: handle button tap here
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Card(
                          color: const Color(0xFF5E92A8),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/buttons/reward_coin.png',
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "$rewardCoinValue",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // -- END of the menu button & reward coin display at the top bar. --

                const SizedBox(height: 5.0),

                // -- START of headline. --
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hi there, $userName.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Chewy',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const RandomTagline(),
                    ],
                  ),
                ),
                // -- END of headline. --

                const SizedBox(height: 10.0),

                // -- START of action buttons inside the body --
                // Let's Cook Button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LetsCook01()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/lets_cook.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ViewMyKitchen01()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/view_my_kitchen.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HelloMyCommunity01()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/hello_my_community.png',
                      width: imageSizeOfButton,
                      height: imageSizeOfButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color(0xFFA48EA1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 30),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      "assets/buttons/close_white.png",
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              settingsButton( // For User Profile
                imagePath: 'assets/buttons/menu_profile.png',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserProfile()),
                  );
                },
              ),
              settingsButton( // For User Achievements
                imagePath: 'assets/buttons/menu_achievements.png',
                onPressed: () {
                  // TODO: Handle button press
                },
              ),
              settingsButton( // For COOKAiGA team
                imagePath: 'assets/buttons/menu_about_us.png',
                onPressed: () {
                  showAboutUsDialog(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showAboutUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color(0xFF336B89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 30),
                  const Text(
                    "About COOKAiGA",
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      "assets/buttons/close_white.png",
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Scrollable Text Content in Center
              SizedBox(
                height: 600, // Adjust height as needed
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [

                        // Mission
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Our Mission",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "To empower individuals with ADHD by making cooking an accessible, engaging, and stress-free experience through AI-driven guidance and interactive features.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 11.0,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Vision
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Our Vision",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "To revolutionise meal preparation for ADHD individuals, fostering independence, healthier eating habits, and a supportive cooking community.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 11.0,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // The COOKAiGA Logo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Why COOKAiGA?",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Image.asset(
                            'assets/buttons/cookaiga_logo_four.png',
                            width: imageSizeOfButton,
                            height: imageSizeOfButton,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "COOKAiGA is derived from 'Kuka' and 'Aiga' (home cooking in Samoan).\n"
                            "\nIts logo reflects its mission to make cooking stress-free and engaging for individuals with ADHD.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 11.0,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // The COOKAiGA Team
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "The COOKAiGA Team",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "At COOKAiGA, we are a passionate team of 3 Nanyang Technological University students.\n"
                            //"\nWe've built a solution that simplifies meal preparation through structured guidance, interactive features, and intelligent recommendations.\n"
                            "\nTogether, we've worked tirelessly to create an app that fosters independence, engagement, and a love for cooking within the ADHD community.\n"
                            "\nJoin us on this journey and cook with confidence!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 11.0,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Credits and Acknowledgement
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "Credits & Acknowledgement",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "COOKAiGA incorporates design assets and music from various sources to enhance user experience. "
                            "Icons and visual elements were created using 'Canva', while background music and sound effects are sourced from licensed libraries to support focus and engagement.\n"
                            "\nWe extend our gratitude to these platforms for their creative resources.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 11.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse('https://www.instagram.com/helyx2024/');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E92A8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Learn More",
                  style: TextStyle(
                    fontFamily: "Chewy",
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget settingsButton({
  required String imagePath,
  required VoidCallback onPressed,
  double size = 180.0, // Default button size
  Color fillColor = const Color(0xFFA48EA1),
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: size * 0.05), // Dynamic padding
    child: RawMaterialButton(
      onPressed: onPressed,
      fillColor: fillColor,
      constraints: BoxConstraints.tightFor(
        width: size,
        height: size,
      ),
      shape: const CircleBorder(),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
      ),
    ),
  );
}

class RandomTagline extends StatefulWidget {
  const RandomTagline({Key? key}) : super(key: key);

  @override
  _RandomTaglineState createState() => _RandomTaglineState();
}

class _RandomTaglineState extends State<RandomTagline> {
  final List<String> taglines = [
    "Let's cook up something special!",
    "Bon Appétit awaits!",
    "Time to whip up magic in the kitchen!",
    "Your culinary adventure starts now!",
    "Heat up your kitchen—fun begins now!",
    "Prepare for a feast of creativity!",
    "Where flavour meets inspiration!",
    "Discover the chef in you!",
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
