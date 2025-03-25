import 'package:flutter/material.dart';

class LetsCook06 extends StatefulWidget {
  final String recipeName;
  final int stepNumber;
  final int totalSteps;
  final String stepDescription;
  final bool isChildsTurn;
  final VoidCallback onNextStep;

  const LetsCook06({
    Key? key,
    required this.recipeName,
    required this.stepNumber,
    required this.totalSteps,
    required this.stepDescription,
    required this.isChildsTurn,
    required this.onNextStep,
  }) : super(key: key);

  @override
  _LetsCook06 createState() => _LetsCook06();
}

class _LetsCook06 extends State<LetsCook06> {
  // Function to determine which image to display based on step description
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

    for (var keyword in imageMap.keys) {
      if (description.toLowerCase().contains(keyword)) {
        return imageMap[keyword];
      }
    }
    return null; // No image if no keywords match
  }

  @override
  Widget build(BuildContext context) {
    String? stepImage = getStepImage(widget.stepDescription);

    return Scaffold(
      backgroundColor: const Color(0xFF80A6A4), // Soft blue background
      body: SafeArea(
        child: Column(
          children: [
            // -- START of Step Progress Indicator --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: widget.stepNumber / widget.totalSteps,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: Colors.orangeAccent,
                minHeight: 8.0,
              ),
            ),
            // -- END of Step Progress Indicator --

            const SizedBox(height: 20.0),

            // -- START of Who’s Cooking Indicator --
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.isChildsTurn
                      ? 'assets/buttons/cooking_child.png'
                      : 'assets/buttons/cooking_adult.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isChildsTurn ? "Your Turn!" : "Adult's Turn!",
                  style: const TextStyle(
                    fontFamily: "Chewy",
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // -- END of Who’s Cooking Indicator --

            const SizedBox(height: 20.0),

            // -- START of Step Description with Image --
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text(
                      "Step ${widget.stepNumber}",
                      style: const TextStyle(
                        fontFamily: "Chewy",
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display Step Image (If Found)
                    if (stepImage != null)
                      Column(
                        children: [
                          Image.asset(
                            stepImage,
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),

                    // Step Description
                    Text(
                      widget.stepDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "VarelaRound",
                        fontSize: 18.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // -- END of Step Description with Image --

            const SizedBox(height: 20.0),

            // -- START of Action Buttons --
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Need Help Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement help feature (voice guidance, tutorial video, etc.)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Need Help?",
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Next Step Button
                ElevatedButton(
                  onPressed: widget.onNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Next Step",
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // -- END of Action Buttons --
          ],
        ),
      ),
    );
  }
}
