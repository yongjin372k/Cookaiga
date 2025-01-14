import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';

class CookingStepsScreen extends StatefulWidget {
  final List<Map<String, String>> steps;

  const CookingStepsScreen({Key? key, required this.steps}) : super(key: key);

  @override
  _CookingStepsScreenState createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    // Parse the current step into category, step number, and content
    final step = widget.steps[currentStep];
    final motivation = step['motivation'] ?? '';
    final stepContent = step['step'] ?? '';

    // Remove the "Step X (Category):" part from stepContent
    final cleanedContent = stepContent.replaceFirst(RegExp(r'^Step \d+ \([^)]+\):\s*'), '');

    // Determine the background color and image based on category
    final categoryRegex = RegExp(r'\((.*?)\)');
    final match = categoryRegex.firstMatch(step['step'] ?? '');
    final category = match != null ? match.group(1)!.toLowerCase() : "unknown";
    String imagePath;
    Color backgroundColor;
    switch (category) {
      case "parent":
        backgroundColor = const Color(0xFFA48EA1); // Purple
        imagePath = 'instructions_parent.png';
        break;
      case "child":
        backgroundColor = const Color(0xFFEDCF9E); // Yellow
        imagePath = 'instructions_child.png';
        break;
      case "everyone":
        backgroundColor = const Color(0xFFAED8C0); // Green
        imagePath = 'instructions_everyone.png';
        break;
      default:
        backgroundColor = Colors.white;
        imagePath = '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9), // Overall screen background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (imagePath.isNotEmpty)
                // Add the image dynamically based on category
                canvaImage(
                  imagePath,
                  width: 200,
                  height: 200,
                ),
              const SizedBox(height: 1), // Spacing after the image
              // Step Card
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95, // 90% of screen width
                      height: MediaQuery.of(context).size.height * 0.57, // 40% of screen height
                      child: Card(
                        color: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Center both vertically
                            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                            children: [
                              // Cooking Process Text (Step Content First)
                              Text(
                                cleanedContent, // Step content
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  height: 1.5,
                                  fontFamily: 'Chewy',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20), // Add small space between content and motivation
                              // Motivational Text
                              if (motivation.isNotEmpty)
                                Text(
                                  motivation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    height: 1.5,
                                    fontFamily: 'Chewy',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Navigation Buttons
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  if (currentStep > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF336A84),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 55  ),
                        child: const Text(
                          "Previous",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Chewy',
                          ),
                        ),
                      ),
                    ),
                  // Next Button
                  GestureDetector(
                    onTap: () {
                      if (currentStep < widget.steps.length - 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        // Finish navigation or show a message
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF336A84),
                        borderRadius: BorderRadius.circular(20),
                        //const BorderSide(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 55),
                      child: Text(
                        currentStep < widget.steps.length - 1 ? "Next Step" : "Finish",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Chewy',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
