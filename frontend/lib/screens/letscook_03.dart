import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/audio_controller.dart';
import 'package:frontend/screens/checklist.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'transition.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

class LetsCook03Content extends StatefulWidget {
  final List<String>? recipes; // Accept recipes as optional

  const LetsCook03Content({Key? key, this.recipes}) : super(key: key);

  @override
  _LetsCook03ContentState createState() => _LetsCook03ContentState();
}


class _LetsCook03ContentState extends State<LetsCook03Content> {
  List<String> recipes = []; // To store recipe names
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipes != null) {
      // Use recipes passed from the previous page
      recipes = widget.recipes!;
    } else {
      // Fetch recipes dynamically if not provided
      fetchRecipes();
    }
  }

  // Settle
  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch recipes from backend (RecipeController)
      final recipeResponse = await http.post(
        Uri.parse('$URL/api/recipes/generate-from-database'),
        headers: {"Content-Type": "application/json"},
      );

      if (recipeResponse.statusCode == 200) {
        final List<String> recipeNames =
            (jsonDecode(recipeResponse.body) as List<dynamic>).cast<String>();

        setState(() {
          recipes = recipeNames;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        recipes = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Settle
  Future<void> fetchRecipeOverview(String recipeName) async {
    try {
      final response = await http.post(
        Uri.parse('$URL2/generate-recipe-overview'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"recipe_name": recipeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure data is properly extracted
        String fetchedRecipeName = data['recipe_name'] ?? "Unknown Recipe";
        List<String> fetchedIngredients = List<String>.from(data['ingredients'] ?? []);
        List<String> fetchedEquipment = List<String>.from(data['equipment'] ?? []);

        if (fetchedRecipeName.isEmpty || fetchedIngredients.isEmpty || fetchedEquipment.isEmpty) {
          throw Exception("Missing data in recipe overview");
        }

        // Join lists into readable text
        String ingredientsText = fetchedIngredients.join("\n");
        String equipmentText = fetchedEquipment.join("\n");

        // Navigate to Checklist Page with Corrected Data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChecklistPage(
              recipeName: fetchedRecipeName,
              ingredients: ingredientsText,
              equipment: equipmentText,
            ),
          ),
        );
      } else {
        throw Exception('Failed to fetch recipe overview');
      }
    } catch (error) {
      print("Error: $error");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to fetch recipe overview: $error"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF80A6A4)),
      body: Stack(
        children: [
          // Background and Top Row
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_view_my_kitchen_01.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LetsCook01Content()),
                          );
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

                // const SizedBox(height: 20),
                
                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                        child: RawMaterialButton(
                          onPressed: () {
                          },
                          fillColor: const Color(0xFF80A6A4),
                          constraints: BoxConstraints.tightFor(
                            width: 125,
                            height: 125,
                          ),
                          shape: const CircleBorder(),
                          child: Image.asset(
                            'assets/buttons/browse_recipes.png',
                            width: 125,
                            height: 125,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : recipes.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No recipes found!",
                                      style: textHeader,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: recipes.length,
                                    itemBuilder: (context, index) {
                                      final recipe = recipes[index];
                                      return GestureDetector(
                                        onTap: () => fetchRecipeOverview(recipe),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                                          decoration: BoxDecoration(
                                            color: createMaterialColor(const Color(0xFFFFF7F0)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              recipe,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                // fontWeight: FontWeight.bold,
                                                height: 1,
                                                color: Colors.black,
                                                fontFamily: 'Chewy',
                                              ),
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: fetchRecipes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDECBB7),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Generate more recipes",
                            style: TextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                              fontFamily: 'Chewy',
                            ),
                          ),
                        ),
                      ),
                    ],
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