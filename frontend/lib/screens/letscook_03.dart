import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
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


  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch recipes from backend
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

  Future<void> fetchRecipeOverview(String recipeName) async {
    try {
      final response = await http.post(
        Uri.parse('$URL2/generate-recipe-overview'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"recipe_name": recipeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> overviewLines = data['overview'];

        // Parse data for recipe overview
        String recipeName = overviewLines.firstWhere(
          (line) => line.toString().startsWith("Recipe name:"),
          orElse: () => "Unknown Recipe", // Default value if not found
        ).replaceFirst("Recipe name:", "").trim();

        String ingredients = overviewLines.skipWhile(
          (line) => !line.toString().startsWith("Ingredients:"),
        ).skip(1).takeWhile((line) => !line.toString().startsWith("Required equipment:")).join("\n").trim();

        String equipment = overviewLines.skipWhile(
          (line) => !line.toString().startsWith("Required equipment:"),
        ).skip(1).join("\n").trim();

        // Navigate to Overview Recipe Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OverviewRecipe(
              recipeName: recipeName,
              ingredients: ingredients,
              equipment: equipment,
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
          // Back Button Positioned at Top-Left
          Positioned(
            top: 10, // Adjust vertical position
            left: 10, // Adjust left margin
            right: 10, // Adjust right margin
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to left
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(fadeTransition(const LetsCook01Content()));
                  },
                  child: canvaImage('back_arrow.png', width: 50, height: 50),
                ),
              ],
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // Space after back button
                      Center(
                        child: canvaImage('browse_recipes.png',
                            width: 120, height: 120),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
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
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: recipes.length,
                                    itemBuilder: (context, index) {
                                      final recipe = recipes[index];
                                      return GestureDetector(
                                        onTap: () => fetchRecipeOverview(recipe),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 30),
                                          decoration: BoxDecoration(
                                            color: createMaterialColor(
                                                const Color(0xFF336B89)),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              recipe,
                                              style: textBody,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      fetchRecipes();
                    },
                    child: const Text(
                      "Generate more recipes",
                      style: textBody,
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF336A84),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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