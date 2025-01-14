import 'package:flutter/material.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'transition.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

class LetsCook10Content extends StatefulWidget {
  final List<String>? recipes; // Accept recipes as optional

  const LetsCook10Content({Key? key, this.recipes}) : super(key: key);

  @override
  _LetsCook10ContentState createState() => _LetsCook10ContentState();
}


class _LetsCook10ContentState extends State<LetsCook10Content> {
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF80A6A4)),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(fadeTransition(const LetsCook01Content()));
                      },
                      child: canvaImage('back_arrow.png', width: 50, height: 50),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: canvaImage('lets_cook_complete.png',
                        width: 300, height: 300),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}