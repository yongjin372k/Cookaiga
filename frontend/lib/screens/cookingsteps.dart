import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/letscook_10.dart';

class CookingStepsScreen extends StatefulWidget {
  final List<Map<String, String>> steps;
  final bool isCookingAlone; // New parameter to differentiate modes
  final String recipeName; // Add recipeName parameter

  const CookingStepsScreen({Key? key, required this.steps, required this.isCookingAlone, required this.recipeName}) : super(key: key);

  @override
  _CookingStepsScreenState createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  int currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the widget is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Start a timer to show the check-in dialog if the user takes too long
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 10), () {
      _showCheckInDialog();
    });
  }

  // Show the check-in dialog
  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF5B98A9),
          title: const Text(
            'How are you doing?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Chewy',
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Take your time, no rush! When you\'re ready, click Continue.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Chewy',
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _startTimer(); // Restart the timer for the next step
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF336A84),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Chewy',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[currentStep];
    final motivation = step['motivation'] ?? '';
    final stepContent = step['step'] ?? '';
    final cleanedContent = stepContent.replaceFirst(RegExp(r'^Step \d+ \([^)]+\):\s*'), '');
    final categoryRegex = RegExp(r'\((.*?)\)');
    final match = categoryRegex.firstMatch(step['step'] ?? '');
    final category = match != null ? match.group(1)!.toLowerCase() : "unknown";

    String imagePath;
    Color backgroundColor;

    if (widget.isCookingAlone) {
      // Default color for "Cooking Alone"
      backgroundColor = const Color(0xFFFCD4E4); // Change this to your preferred default color
      imagePath = 'cooking_alone_logo.png'; // Use the default image
    } else {
      // Determine background color and image based on the category
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
          backgroundColor = Colors.white; // Default background color
          imagePath = '';
          break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (imagePath.isNotEmpty)
                canvaImage(
                  imagePath,
                  width: 200,
                  height: 200,
                ),
              const SizedBox(height: 1),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: Card(
                        color: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Cooking Process Text (Step Content First)
                                  Text(
                                    cleanedContent,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.black,
                                      height: 1.5,
                                      fontFamily: 'Chewy',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40), // Add space between content and motivation
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Step ${currentStep + 1} of ${widget.steps.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Chewy',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / widget.steps.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336A84)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentStep--;
                          _timer?.cancel(); // Cancel the previous timer
                          _startTimer(); // Start a new timer
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF336A84),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 55),
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
                  GestureDetector(
                    onTap: () {
                      if (currentStep < widget.steps.length - 1) {
                        setState(() {
                          currentStep++;
                          _timer?.cancel(); // Cancel the previous timer
                          _startTimer(); // Start a new timer
                        });
                      } else {
                        setState(() {
                          _timer?.cancel();
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LetsCook10Content(
                              recipeName: widget.recipeName, // Pass the recipe name
                              coinsEarned: 20, // Pass default coins earned
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF336A84),
                        borderRadius: BorderRadius.circular(20),
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