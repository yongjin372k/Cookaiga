import 'dart:io';
import 'package:flutter/material.dart';
import 'page_lets_cook_01.dart';
import 'page_lets_cook_04.dart';
import '../controller/audio_controller.dart';

final double imageSizeOfHeader = 150.0;

class LetsCook03 extends StatefulWidget {
  final String imagePath;

  const LetsCook03({Key? key, required this.imagePath}) : super(key: key);

  @override
  _LetsCook03State createState() => _LetsCook03State();
}

class _LetsCook03State extends State<LetsCook03> {
  final List<String> allRecipes = [
    'Classic Chicken Mushroom Risotto',
    'Creamy Chicken & Mushroom Rice Soup',
    'Baked Chicken Mushroom Casserole',
    'Herbed Chicken Mushroom Rice Pilaf',
    'Garlic Butter Chicken Rice',
    'Spicy Cajun Chicken Pasta',
    'Lemon Herb Chicken Quinoa Bowl',
    'Mushroom and Spinach Stuffed Chicken',
    'Chicken Teriyaki Stir Fry',
    'Cheesy Chicken and Broccoli Casserole',
  ];

  List<String> displayedRecipes = [];

  @override
  void initState() {
    super.initState();
    _generateInitialRecipes(); // Pick 4 recipes on page load
  }

  void _generateInitialRecipes() {
    setState(() {
      displayedRecipes = _getRandomRecipes(4);
    });
  }

  List<String> _getRandomRecipes(int count) {
    List<String> availableRecipes =
        allRecipes.where((recipe) => !displayedRecipes.contains(recipe)).toList();

    if (availableRecipes.length <= count) {
      return availableRecipes; // Return all remaining recipes if fewer than requested
    }

    availableRecipes.shuffle(); // Randomize list order
    return availableRecipes.sublist(0, count);
  }

  void _generateMoreRecipes() {
    setState(() {
      displayedRecipes.addAll(_getRandomRecipes(4));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF80A6A4),
      body: SafeArea(
        child: Column(
          children: [
            // -- START of back button and Browse Recipe headline. --
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40 * 0.05),
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LetsCook01()),
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
                  ),

                  // Centered Headline Image
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/buttons/browse_recipes.png',
                        width: imageSizeOfHeader,
                        height: imageSizeOfHeader,
                      ),
                    ),
                  ),

                  // Music Toggle Button
                  RawMaterialButton(
                    onPressed: () async {
                      await toggleMusic();
                      setState(() {}); // Ensure UI updates when toggled
                    },
                    fillColor: const Color(0xFF5E92A8),
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    shape: const CircleBorder(),
                    child: Image.asset(
                      isMusicOn ? 'assets/buttons/sound_on_white.png' : 'assets/buttons/sound_off_white.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
            // -- END of back button and Browse Recipe headline. --

            // -- START of optional captured image. --
            if (widget.imagePath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(widget.imagePath),
                  width: imageSizeOfHeader,
                  fit: BoxFit.cover,
                ),
              ),
            // -- END of optional captured image. --

            // -- START of recipe list. --
            Expanded(
              child: ListView.builder(
                itemCount: displayedRecipes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LetsCook04(recipeName: displayedRecipes[index],)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          displayedRecipes[index],
                          style: const TextStyle(
                            fontFamily: 'Chewy',
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // -- END of recipe list --

            const SizedBox(height: 10),

            // -- START of Generate More Recipes Button --
            ElevatedButton(
              onPressed: displayedRecipes.length < allRecipes.length ? _generateMoreRecipes : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: displayedRecipes.length < allRecipes.length
                    ? const Color(0xFF5E92A8)
                    : Colors.grey.withOpacity(0.6), // Disable button when all recipes are shown
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                displayedRecipes.length < allRecipes.length ? "Generate More" : "No More Recipes",
                style: const TextStyle(
                  fontFamily: "Chewy",
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
            // -- END of Generate More Recipes Button --
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
