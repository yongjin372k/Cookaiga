import 'package:flutter/material.dart';
import 'package:frontend/screens/cookingsteps.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/screens/letscook_05.dart';
import 'package:frontend/screens/letscook_06.dart';
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
      final url = Uri.parse('http://10.0.2.2:5000/generate-recipe-steps');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipe_name': recipeName,
          'ingredients': ingredients.split('\n'),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      backgroundColor: createMaterialColor(const Color(0xFF5B98A9)),
      body: Stack(
        children: [
          // Back Button Positioned
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: canvaImage('back_arrow.png', width: 50, height: 50),
                ),
              ],
            ),
          ),

          // Main Content
          Column(
            children: [
              const SizedBox(height: 60), // Space below the back button
              const Text(
                "Overview",
                style: textPageHeader,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Add some spacing
              Expanded(
                child: Center(
                  child: Card(
                    color: const Color(0xFF80A6A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: SizedBox(
                      height: 475,
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
                                style: textHeader,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Ingredients",
                                style: textHeader,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ingredients,
                                style: textBody,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Required Items",
                                style: textHeader,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                equipment,
                                style: textBody,
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
                          builder: (context) => LetsCook05Content(
                            onNext: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LetsCook06Content(
                                    onNext: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CookingStepsScreen(
                                            steps: steps,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to fetch steps. Please try again later.'),
                        ),
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
                    style: textBody,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
