import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/audio_controller.dart';
import 'package:frontend/screens/camera_screen.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'package:frontend/screens/recipe_screen.dart';
import 'package:http/http.dart' as http;
import 'design.dart';
import 'homepage.dart';
import 'transition.dart';
import 'letscook_03.dart';

class LetsCook01Content extends StatelessWidget {
  const LetsCook01Content({super.key});

  Future<void> _handleBrowseRecipes(BuildContext context) async {
    try {
      print("Fetching ingredients...");

      final ingredientResponse = await http.get(
        Uri.parse('$URL2/ingredients'),
        headers: {"Content-Type": "application/json"},
      );

      print("Ingredient status: ${ingredientResponse.statusCode}");
      print("Ingredient response body: ${ingredientResponse.body}");
      final decoded = jsonDecode(ingredientResponse.body);

      if (decoded is Map<String, dynamic> && decoded['ingredients'] is List) {
        final ingredients = List<String>.from(decoded['ingredients']);
        // final ingredients = data['ingredients'] as List<dynamic>;

        print("🧂 Ingredients parsed: $ingredients");

        if (ingredients.isEmpty) {
          print("No ingredients found, showing dialog.");
          _showIngredientDialog(context);
          return;
        }

        print("Generating recipes with ingredients...");
        final recipeResponse = await http.post(
          // Uri.parse('$URL/api/recipes/generate-from-database'),
          Uri.parse('$URL/api/recipes/generate-from-database'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"ingredients": ingredients}),
        );

        print("Recipe status: ${recipeResponse.statusCode}");
        print("Recipe response body: ${recipeResponse.body}");

        if (recipeResponse.statusCode == 200) {
          final recipeData = jsonDecode(recipeResponse.body);

          if (recipeData is List && recipeData.isNotEmpty) {
            final recipes = List<String>.from(recipeData);
            print("✅ Recipes received: $recipes");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LetsCook03Content(recipes: recipes)),
            );
          } else {
            _showIngredientDialog(context); // fallback
          }
        } else {
          throw Exception("Failed to generate recipes");
        }
      } else {
        throw Exception("Failed to fetch ingredients");
      }
    } catch (error) {
      print("Error occurred: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  void _showIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF0E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("No Ingredients Found", style: TextStyle(fontFamily: 'Chewy')),
        content: const Text(
          "You need ingredients in your kitchen to generate recipes. Please scan or add ingredients first.",
          style: TextStyle(fontFamily: 'Chewy'),
        ),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(fontFamily: 'Chewy')),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_lets_cook_01.png',
              fit: BoxFit.cover,
            ),
          ),

          // Top Left Custom Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Row(
                children: [
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    fillColor: const Color(0xFF5E92A8),
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/back_arrow.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Let's cook up \nsomething special!",
                  style: TextStyle(
                    fontSize: 26,
                    // fontWeight: FontWeight.bold,
                    fontFamily: 'Chewy',
                    color: Color.fromRGBO(255, 255, 255, 1),
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () {
                      if (isMusicOn) toggleMusic(); // Stop music before navigating
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CameraPage()),
                      );
                    },
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: 150,
                      height: 150,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/scan_ingredients.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dynamicVerticalPadding),
                  child: RawMaterialButton(
                    onPressed: () => _handleBrowseRecipes(context),
                    fillColor: const Color(0xFF80A6A4),
                    constraints: BoxConstraints.tightFor(
                      width: 150,
                      height: 150,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/buttons/browse_recipes.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
