import 'package:flutter/material.dart';

class CookingStepsScreen extends StatefulWidget {
  final List<Map<String, String>> steps; // Update to List<Map<String, String>>

  const CookingStepsScreen({Key? key, required this.steps}) : super(key: key);

  @override
  _CookingStepsScreenState createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  int currentStep = 0; // Track the current step index

  @override
  Widget build(BuildContext context) {
    // Parse the current step into category, step number, and content
    final step = widget.steps[currentStep];
    final motivation = step['motivation'] ?? '';
    final stepContent = step['step'] ?? '';

    // Remove the "Step X (Category):" part from stepContent
    final cleanedContent = stepContent.replaceFirst(RegExp(r'^Step \d+ \([^)]+\):\s*'), '');

    // Determine the background color based on category
    final categoryRegex = RegExp(r'\((.*?)\)');
    final match = categoryRegex.firstMatch(step['step'] ?? '');
    final category = match != null ? match.group(1)!.toLowerCase() : "unknown";

    Color backgroundColor;
    switch (category) {
      case "parent":
        backgroundColor = const Color(0xFFB39DDB); // Purple
        break;
      case "child":
        backgroundColor = const Color(0xFFFFF176); // Yellow
        break;
      case "everyone":
        backgroundColor = const Color(0xFF80CBC4); // Green
        break;
      default:
        backgroundColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9), // Overall screen background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step Card
              Card(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Cooking Process Text (Step Content First)
                      Text(
                        cleanedContent, // Step content
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Comic Sans MS',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20), // Add space between step content and motivation
                      // Motivational Text (Now Below)
                      if (motivation.isNotEmpty)
                        Text(
                          motivation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Comic Sans MS',
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  if (currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF336A84),
                      ),
                      child: const Text(
                        "Previous",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  // Next Button
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep < widget.steps.length - 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        // Finish navigation or show a message
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF336A84),
                    ),
                    child: Text(
                      currentStep < widget.steps.length - 1 ? "Next Step" : "Finish",
                      style: const TextStyle(color: Colors.white),
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
