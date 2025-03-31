import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/letscook_10.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math'; // Import this for Random

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
  late FlutterTts flutterTts;
  bool isSpeaking = false; // Track if TTS is speaking
  late ConfettiController _confettiController;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late String instructionText;
  late String selectedPrompt;
  final List<String> encouragements = [
    "Great job! Keep going!",
    "You're doing amazing!",
    "Awesome work! Let's move on.",
    "You're a fantastic cook!",
    "Keep it up! You're almost there!"
  ];

  final Random _random = Random();

  final List<String> cookingPrompts = [
    "Take your time, no rush! When you're ready, \nclick Continue.",
    "No pressure—go at your \nown pace!",
    "Ready when you are! \nClick continue to move on.",
    "Enjoy the moment. \nContinue when you're set.",
    "Don't worry, you’re doing great. \nHit continue when ready!",
    "Need a breather? \nCome back when you're ready.",
    "Feel free to explore. \nTap continue when you're done.",
    "You're in control! \nContinue when it feels right.",
    "Whenever you're ready, \nlet's move forward.",
    "Pause if you need to. \nContinue when you're comfortable.",
  ];

  String? getStepImage(String description) {
    final Map<String, String> imageMap = {
      "chop": "assets/cooking_icons/chopping_board.png",
      "slice": "assets/cooking_icons/chopping_board.png",
      "cut": "assets/cooking_icons/chopping_board.png",
      "add sauce": "assets/cooking_icons/add_sauce.png",
      "pour": "assets/cooking_icons/add_sauce.png",
      "mix": "assets/cooking_icons/mixing_bowl.png",
      "stir-fry": "assets/cooking_icons/frying_pan.png",
      "stir": "assets/cooking_icons/mixing_bowl.png",
      "fry": "assets/cooking_icons/frying_pan.png",
      "saute": "assets/cooking_icons/frying_pan.png",
      "heat": "assets/cooking_icons/heat.png",
      "rice": "assets/cooking_icons/rice.png",
    };

    description = description.toLowerCase();
    for (final key in imageMap.keys) {
      if (description.contains(key)) {
        return imageMap[key];
      }
    }
    return null;
  }

  

  @override
  void initState() {
    super.initState();

    selectedPrompt = cookingPrompts[Random().nextInt(cookingPrompts.length)];

    
    _initTts();
    _startTimer(); // Start the timer when the widget is initialized
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _speech = stt.SpeechToText();
    

    // Speak Step 1 when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakEncouragementAndStep(widget.steps[currentStep]['step'] ?? '');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  // Initialize Text-to-Speech
  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('🎙 Speech status: $status');
        setState(() {
          _isListening = status == "listening"; // Update UI when listening
        });
      },
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          String command = result.recognizedWords.toLowerCase();
          print("User said: $command");

          if (command.contains("next step")) {
            print("Recognized 'Next Step' command!");
            _speech.stop(); // Stop listening
            setState(() => _isListening = false); // Update UI
            _goToNextStep();
          }
        },
      );
    } else {
      print("Speech Recognition not available");
      setState(() => _isListening = false);
    }
  }

  void _goToNextStep() {
    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
        _timer?.cancel(); // Cancel the previous timer
        _startTimer(); // Start a new timer
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _speakEncouragementAndStep(widget.steps[currentStep]['step'] ?? '');
      });

      _startListening(); // Start voice recognition for "Next Step"
    } else {
      setState(() {
        _confettiController.play(); // 🎉 Trigger Confetti
        _timer?.cancel();
      });

      // Speak final encouragement before navigating
      String finalEncouragement = "Congratulations! You've completed" + widget.recipeName + "Well done!";
      flutterTts.speak(finalEncouragement).then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LetsCook10Content(
                recipeName: widget.recipeName, // Pass the recipe name
                coinsEarned: 20, // Reward user for finishing
              ),
            ),
          );
        });
      });
    }
  }


  // Read step aloud
  Future<void> _speakEncouragementAndStep(String text) async {
    if (!isSpeaking) {
      setState(() {
        isSpeaking = true;
      });

      // Skip encouragement for the first step
      if (currentStep > 0) {
        String encouragement = encouragements[_random.nextInt(encouragements.length)];
        await flutterTts.speak(encouragement);
        await Future.delayed(Duration(seconds: 3)); // Ensure a small delay before continuing
      }

      // Speak the step after encouragement
      await flutterTts.speak(text);

      // Set speaking state to false after speech is done
      setState(() {
        isSpeaking = false;
      });
    }
  }




  // Start a timer to show the check-in dialog if the user takes too long
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 10), () {
      _showCheckInDialog();
    });
  }
  

  // Show the check-in dialog
  void _showCheckInDialog() {
    selectedPrompt = cookingPrompts[_random.nextInt(cookingPrompts.length)];
    
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
          content: Text(
            selectedPrompt,
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
    final stepImage = getStepImage(cleanedContent);

    String imagePath;
    Color backgroundColor;

    if (widget.isCookingAlone) {
      // Default color for "Cooking Alone"
      backgroundColor = const Color(0xFFFCD4E4); // Change this to your preferred default color
      imagePath = 'cooking_alone.png'; // Use the default image
      instructionText = "Your Turn!";
    } else {
      // Determine background color and image based on the category
      switch (category) {
        case "parent":
          backgroundColor = const Color(0xFFA48EA1); // Purple
          imagePath = 'cooking_adult.png';
          instructionText = "Adult's Turn!";
          break;
        case "child":
          backgroundColor = const Color(0xFFEDCF9E); // Yellow
          imagePath = 'cooking_child.png';
          instructionText = "Child's Turn!";
          break;
        case "everyone":
          backgroundColor = const Color(0xFFAED8C0); // Green
          imagePath = 'cooking_together.png';
          instructionText = "Everyone Together!";
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
              ConfettiWidget(
                confettiController: _confettiController, // 🎉 Confetti Effect
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                maxBlastForce: 20, // More explosion power
                minBlastForce: 5, // Less explosion power
                emissionFrequency: 0.03,
                numberOfParticles: 30, // Increase for more confetti
                gravity: 0.1, // Slow falling effect
                colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
              ),
              const SizedBox(height: 25),
              if (imagePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    canvaImage(
                      imagePath,
                      width: 125,
                      height: 125,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      instructionText,
                      style: textHeader, // use your existing text style
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                                  if (stepImage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Image.asset(
                                      stepImage,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                    onTap: () => _goToNextStep(),
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