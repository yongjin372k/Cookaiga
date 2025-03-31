import 'dart:convert';
import 'package:frontend/screens/audio_controller.dart';
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
  late Map<String, String> ingredientAlternatives;  
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
    ingredientAlternatives = {for (var ingredient in ingredientList) ingredient: ingredient};

    equipmentChecklist = {for (var equipment in equipmentList) equipment: false};
  }
  

  // Check if all checklist items are checked
  bool _isReadyToCook() {
    return ingredientChecklist.values.every((isChecked) => isChecked) &&
        equipmentChecklist.values.every((isChecked) => isChecked);
  }

  Future<void> fetchStepsAndNavigate() async {
    List<String> missingIngredients = ingredientChecklist.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    List<String> missingEquipment = equipmentChecklist.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    if (missingIngredients.isNotEmpty || missingEquipment.isNotEmpty) {
      // Show warning dialog if any item is missing
      _showMissingItemsDialog(missingIngredients, missingEquipment);
    } else {
      // If everything is checked, navigate directly
      _navigateToCookingSteps();
    }
  }

  void _showMissingItemsDialog(List<String> missingIngredients, List<String> missingEquipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        backgroundColor: Color(0xFF5B98A9), // Match checklist page background
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.yellow, size: 28),
            SizedBox(width: 10),
            Text(
              "Warning",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                fontFamily: 'Chewy',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (missingIngredients.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.redAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Missing Ingredients:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Chewy',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              ...missingIngredients.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 30.0, bottom: 3),
                  child: Text(
                    "• $item",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Chewy'),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
            if (missingEquipment.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.report_problem_rounded, color: Colors.orangeAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Missing Equipment:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Chewy',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              ...missingEquipment.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 30.0, bottom: 3),
                  child: Text(
                    "• $item",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Chewy'),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Cancel button (Go Back)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.white, // White button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Go Back",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Chewy'),
            ),
          ),
          // Proceed button (Continue cooking)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Color(0xFF336A84), // Dark blue theme color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _navigateToCookingSteps();
            },
            child: Text(
              "Proceed Anyway",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Chewy'),
            ),
          ),
        ],
      ),
    );
  }

  // void _navigateToCookingSteps() async {
  //   setState(() {
  //     isFetchingSteps = true; // Show loading indicator
  //   });

  //   try {
  //     final url = Uri.parse('$URL2/generate-recipe-steps');
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'recipe_name': widget.recipeName,
  //         'ingredients': ingredientChecklist.keys.toList(),
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final List<Map<String, String>> steps = (data['steps'] as List<dynamic>)
  //           .map((step) => {
  //                 'motivation': (step['motivation'] ?? "").toString(),
  //                 'step': (step['step'] ?? "").toString(),
  //               })
  //           .toList();

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => LetsCook05Content(
  //             onModeSelected: (isCookingAlone) {
  //               if (isCookingAlone) {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => CookingStepsScreen(
  //                       steps: steps,
  //                       isCookingAlone: true,
  //                       recipeName: widget.recipeName,
  //                     ),
  //                   ),
  //                 );
  //               } else {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => LetsCook06Content(
  //                       onNext: () {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => CookingStepsScreen(
  //                               steps: steps,
  //                               isCookingAlone: false,
  //                               recipeName: widget.recipeName,
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ),
  //       );
  //     } else {
  //       throw Exception('Failed to fetch steps: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error fetching steps: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to fetch steps. Please try again later.'),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       isFetchingSteps = false; // Hide loading indicator
  //     });
  //   }
  // }

  void _navigateToCookingSteps() async {
    setState(() {
      isFetchingSteps = true; // Show loading indicator
    });

    try {
      // ✅ DEBUG: Log ingredients being deducted
      final ingredientsToDeduct = ingredientChecklist.keys.toList();
      print("🧾 Deducting the following ingredients: $ingredientsToDeduct");

      // 🔁 Step 1: Deduct ingredients from backend
      final deductResponse = await http.post(
        Uri.parse('$URL2/deduct-ingredients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredients': ingredientsToDeduct,
        }),
      );

      if (deductResponse.statusCode != 200) {
        print("❗Failed to deduct ingredients: ${deductResponse.body}");
        throw Exception("Deduct failed");
      } else {
        print("✅ Ingredients deducted");
        
      }

      // 🔁 Step 2: Generate recipe steps
      final stepsResponse = await http.post(
        Uri.parse('$URL2/generate-recipe-steps'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipe_name': widget.recipeName,
          'ingredients': ingredientChecklist.keys.toList(),
        }),
      );

      if (stepsResponse.statusCode == 200) {
        final data = jsonDecode(stepsResponse.body);
        final List<Map<String, String>> steps = (data['steps'] as List<dynamic>)
            .map((step) => {
                  'motivation': (step['motivation'] ?? "").toString(),
                  'step': (step['step'] ?? "").toString(),
                })
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetsCook05Content(
              onModeSelected: (isCookingAlone) {
                if (isCookingAlone) {
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
        throw Exception('Failed to fetch steps: ${stepsResponse.statusCode}');
      }
    } catch (error) {
      print('❌ Error during cooking start: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start cooking. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        isFetchingSteps = false; // Hide loading indicator
      });
    }
  }


  /// Show a swap dialog with alternative ingredient options
  void _showSwapDialog(String ingredient, List<String> alternatives) {
    String selectedAlternative = alternatives.isNotEmpty ? alternatives[0] : ingredient;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( //Use StatefulBuilder to refresh UI
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Color(0xFF5B98A9), // Match checklist background
            title: Text(
              "Swap Ingredient",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white, fontFamily: 'Chewy'),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose an alternative for:",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Chewy'),
                ),
                Text(
                  ingredient,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellowAccent, fontFamily: 'Chewy'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                /// **Enhanced Dropdown Button**
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedAlternative,
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFF336A84), size: 28),
                      dropdownColor: Colors.white,
                      style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Chewy'),
                      borderRadius: BorderRadius.circular(12),
                      items: alternatives.map((alt) {
                        return DropdownMenuItem(
                          value: alt,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              alt,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() { //This updates the dropdown in real-time
                          selectedAlternative = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.black, fontFamily: 'Chewy')),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  backgroundColor: Color(0xFF336A84),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() { //Update checklist in main state
                    bool isChecked = ingredientChecklist[ingredient] ?? false;
                    ingredientChecklist.remove(ingredient);
                    ingredientChecklist[selectedAlternative] = isChecked;
                  });
                  Navigator.pop(context);
                },
                child: Text("Swap", style: TextStyle(color: Colors.white, fontFamily: 'Chewy')),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Fetch alternative ingredients using GPT-3.5 via Flask backend
  Future<void> _fetchIngredientAlternatives(String ingredient) async {
    try {
      final response = await http.post(
        Uri.parse('$URL2/swap-ingredient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"ingredient": ingredient}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> alternatives = List<String>.from(data['alternatives']);

        _showSwapDialog(ingredient, alternatives);
      } else {
        throw Exception('Failed to fetch alternatives');
      }
    } catch (error) {
      print("Error fetching alternatives: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF5B98A9)),
      body: Stack(
        children: [
          // Back Button Positioned
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_view_my_kitchen_01.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back instead of pushing new page
                  },
                  fillColor: const Color(0xFF4A90A4),
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  shape: const CircleBorder(),
                  child: Image.asset(
                    'assets/buttons/back_arrow.png',
                    width: 40,
                    height: 40,
                  ),
                ),
      
                // Sound toggle
                RawMaterialButton(
                  onPressed: () async {
                    await toggleMusic();
                    setState(() {}); // Ensure UI updates
                  },
                  fillColor: const Color(0xFF4A90A4),
                  constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  shape: const CircleBorder(),
                  child: Image.asset(
                    isMusicOn
                        ? 'assets/buttons/sound_on_white.png'
                        : 'assets/buttons/sound_off_white.png',
                    width: 25,
                    height: 25,
                  ),
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
                        // Ingredients Card with Swap Button
                        Card(
                          color: const Color(0xFF80A6A4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  (ingredient) => Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: CheckboxListTile(
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
                                              ingredientChecklist[ingredient] = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.swap_horiz, color: Colors.white),
                                        onPressed: () => _fetchIngredientAlternatives(ingredient),
                                      ),
                                    ],
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
                    onPressed: fetchStepsAndNavigate, // ✅ Always clickable
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF336A84), // 🔹 Keeps the original color
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text(
                      "begin cooking!",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Chewy',
                        color: Colors.white, // ✅ Always visible in white
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
