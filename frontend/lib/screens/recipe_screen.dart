import 'package:flutter/material.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<String> recipes = []; // To store recipe names
  bool isLoading = false;

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch recipes from backend
      final recipeResponse = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/recipes/generate-from-database'),
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
        Uri.parse('http://10.0.2.2:5000/generate-recipe-overview'),
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
      backgroundColor: const Color(0xFF5B98A9),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : recipes.isEmpty
                    ? const Center(
                        child: Text(
                          "No recipes fetched yet!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return GestureDetector(
                              onTap: () => fetchRecipeOverview(recipe),
                              child: Card(
                                color: const Color(0xFF80A6A4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      recipe,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: fetchRecipes,
              child: const Text(
                "Generate more !!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
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
    );
  }
}
