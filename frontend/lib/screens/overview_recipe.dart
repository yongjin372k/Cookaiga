import 'package:flutter/material.dart';

class OverviewRecipe extends StatelessWidget {
  final String recipeName;
  final String ingredients;
  final String equipment;

  const OverviewRecipe({
    Key? key,
    required this.recipeName,
    required this.ingredients,
    required this.equipment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B98A9),
        elevation: 0,
        title: Column(
          children: [
            const SizedBox(height: 30), // Add margin on top of the "Overview" text
            const Text(
              "Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Comic Sans MS',
              ),
            ),
          ],
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Comic Sans MS',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Card(
                color: const Color(0xFF80A6A4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: SizedBox(
                  height: 400, // Set a fixed height for the card
                  width: double.infinity, // Make it take the full width of the screen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            recipeName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comic Sans MS',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comic Sans MS',
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ingredients,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Comic Sans MS',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Required Items",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Comic Sans MS',
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            equipment,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Comic Sans MS',
                              color: Colors.white,
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Implement your functionality here
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF336A84),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              child: const Text(
                "begin cooking!",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Comic Sans MS',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
