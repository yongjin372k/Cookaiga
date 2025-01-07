import 'package:flutter/material.dart';
import 'package:frontend/screens/cookingsteps.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<List<Map<String, String>>> fetchSteps(String recipeName, String ingredients) async {
    try {
      // Replace with your backend API endpoint
      final url = Uri.parse('http://10.0.2.2:5000/generate-recipe-steps');
      
      // Make a POST request with the recipe name as a payload
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipe_name': recipeName,
          'ingredients': ingredients.split('\n'), // Convert ingredients into a list
        }),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Extract the steps from the response
        final List<Map<String, String>> steps = (data['steps'] as List<dynamic>)
            .map((step) => {
                  'motivation': (step['motivation'] ?? "").toString(),
                  'step': (step['step'] ?? "").toString(),
                })
            .toList();

        return steps;
      } else {
        throw Exception('Failed to fetch steps: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching steps: $error');
      throw Exception('Could not fetch steps. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B98A9),
        elevation: 0,
        title: Column(
          children: [
            const SizedBox(height: 30),
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
                  height: 400,
                  width: double.infinity,
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
              onPressed: () async {
                try {
                  final steps = await fetchSteps(recipeName, ingredients);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CookingStepsScreen(steps: steps),
                    ),
                  );
                } catch (error) {
                  // Handle the error (e.g., show a snackbar or alert dialog)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch steps. Please try again later.')),
                  );
                }
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