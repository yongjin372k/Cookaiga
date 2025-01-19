import 'dart:convert';
import 'package:frontend/screens/letscook_05.dart';
import 'package:frontend/screens/letscook_06.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/cookingsteps.dart';

class ChecklistPage extends StatefulWidget {
  final String recipeName;
  final String ingredients;
  final String equipment;

  const ChecklistPage({
    Key? key,
    required this.recipeName,
    required this.ingredients,
    required this.equipment,
  }) : super(key: key);

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  late Map<String, bool> ingredientChecklist;
  late Map<String, bool> equipmentChecklist;
  bool isFetchingSteps = false; // Track the state of fetching steps

  @override
  void initState() {
    super.initState();

    // Parse ingredients and equipment into checklist maps
    final ingredientList = widget.ingredients.split('\n').map((e) => e.trim());
    final equipmentList = widget.equipment.split('\n').map((e) => e.trim());

    ingredientChecklist = {for (var ingredient in ingredientList) ingredient: false};
    equipmentChecklist = {for (var equipment in equipmentList) equipment: false};
  }

  // Check if all checklist items are checked
  bool _isReadyToCook() {
    return ingredientChecklist.values.every((isChecked) => isChecked) &&
        equipmentChecklist.values.every((isChecked) => isChecked);
  }

  Future<void> fetchStepsAndNavigate() async {
    setState(() {
      isFetchingSteps = true; // Show loading indicator
    });

    try {
      // Fetch steps from the backend
      final url = Uri.parse('$URL2/generate-recipe-steps');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipe_name': widget.recipeName,
          'ingredients': widget.ingredients.split('\n'),
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

        // Navigate to LetsCook05Content first for mode selection
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetsCook05Content(
              onModeSelected: (isCookingAlone) {
                if (isCookingAlone) {
                  // Navigate to CookingStepsScreen for "Cooking Alone"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CookingStepsScreen(
                        steps: steps,
                        isCookingAlone: true,
                        recipeName: widget.recipeName,
                      ),
                    ),
                  );
                } else {
                  // Navigate to LetsCook06Content for "Co-op Mode"
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
                                isCookingAlone: false,
                                recipeName: widget.recipeName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('Failed to fetch steps: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching steps: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch steps. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        isFetchingSteps = false; // Hide loading indicator
      });
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
            top: 10,
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40), // Space below the back button

                // Title Section
                const Text(
                  "Checklist",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
                ),

                const SizedBox(height: 15),

                // Recipe Title
                Text(
                  widget.recipeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Checklist Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListView(
                      children: [
                        // Ingredients Card
                        Card(
                          color: const Color(0xFF80A6A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ingredients",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Chewy',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...ingredientChecklist.keys.map(
                                  (ingredient) => CheckboxListTile(
                                    activeColor: const Color(0xFF336A84),
                                    checkColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Chewy',
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: ingredientChecklist[ingredient],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        ingredientChecklist[ingredient] =
                                            value ?? false;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Equipment Card
                        Card(
                          color: const Color(0xFF80A6A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Required Items",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Chewy',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...equipmentChecklist.keys.map(
                                  (equipment) => CheckboxListTile(
                                    activeColor: const Color(0xFF336A84),
                                    checkColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      equipment,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Chewy',
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: equipmentChecklist[equipment],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        equipmentChecklist[equipment] =
                                            value ?? false;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Start Cooking Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isReadyToCook() && !isFetchingSteps
                        ? fetchStepsAndNavigate
                        : null, // Disable button if not ready
                    style: ElevatedButton.styleFrom(
                      primary: _isReadyToCook()
                          ? const Color(0xFF336A84)
                          : Colors.grey, // Change color based on readiness
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: isFetchingSteps
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            "begin cooking!",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Chewy',
                              color: _isReadyToCook() ? Colors.white : Colors.black26,
                            ),
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
