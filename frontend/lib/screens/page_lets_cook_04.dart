import 'package:flutter/material.dart';
import 'page_lets_cook_01.dart';
import 'page_lets_cook_05.dart';
import '../controller/audio_controller.dart';

final double imageSizeOfHeader = 150.0;

class LetsCook04 extends StatefulWidget {
  final String recipeName;

  const LetsCook04({Key? key, required this.recipeName}) : super(key: key);

  @override
  _LetsCook04 createState() => _LetsCook04();
}

class _LetsCook04 extends State<LetsCook04> {
  final Map<String, List<String>> recipeIngredients = {
    'Chicken Teriyaki Stir Fry': [
      '2 boneless chicken thighs',
      '1/4 cup soy sauce',
      '1 tablespoon honey',
      '1 teaspoon ginger (minced)',
      '1 teaspoon garlic (minced)',
      '1/2 cup bell peppers (sliced)',
      '1/2 cup broccoli florets',
      '1 tablespoon sesame oil',
      'Cooked rice (for serving)',
    ],
    'Classic Chicken Mushroom Risotto': [
      '1 cup Arborio rice',
      '2 cups chicken broth',
      '1/2 cup mushrooms (sliced)',
      '1/2 cup cooked chicken (diced)',
      '1/4 cup Parmesan cheese',
      '1/4 cup onions (chopped)',
      '2 tablespoons butter',
      'Salt and pepper to taste',
    ],
  };

  final Map<String, List<String>> requiredItems = {
    'Chicken Teriyaki Stir Fry': [
      'Frying pan',
      'Spatula',
      'Mixing bowl',
      'Cutting board',
    ],
    'Classic Chicken Mushroom Risotto': [
      'Saucepan',
      'Wooden spoon',
      'Knife',
    ],
  };

  final Map<String, bool> checkedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeChecklist();
  }

  void _initializeChecklist() {
    final ingredients = recipeIngredients[widget.recipeName] ?? [];
    final items = requiredItems[widget.recipeName] ?? [];

    for (String item in [...ingredients, ...items]) {
      checkedItems[item] = false;
    }
  }

  bool _allChecked() {
    return checkedItems.values.every((checked) => checked);
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = recipeIngredients[widget.recipeName] ?? [];
    final items = requiredItems[widget.recipeName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF80A6A4),
      body: SafeArea(
        child: Column(
          children: [
            // -- START of Back Button, Headline, and Music Toggle --
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
                        _showBackConfirmationDialog(context);
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
            // -- END of Back Button, Headline, and Music Toggle --

            const SizedBox(height: 10),

            // Page Title
            const Text(
              "Checklist for Cooking",
              style: TextStyle(
                fontFamily: 'Chewy',
                fontSize: 24,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // Ingredients Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    "Ingredients Needed",
                    style: const TextStyle(
                      fontFamily: 'Chewy',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  ...ingredients.map((ingredient) => _buildChecklistItem(ingredient)),

                  const SizedBox(height: 20),

                  // Required Items Section
                  Text(
                    "Required Cooking Tools",
                    style: const TextStyle(
                      fontFamily: 'Chewy',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  ...items.map((item) => _buildChecklistItem(item)),
                ],
              ),
            ),

            // "Begin Cooking" Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _allChecked()
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LetsCook05(),
                          ),
                        );
                      }
                    : null, // Disable if not all are checked
                style: ElevatedButton.styleFrom(
                  backgroundColor: _allChecked() ? const Color(0xFF5E92A8) : Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Begin Cooking!",
                  style: TextStyle(
                    fontFamily: "Chewy",
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Checklist item widget
  Widget _buildChecklistItem(String item) {
    return CheckboxListTile(
      title: Text(
        item,
        style: const TextStyle(
          fontFamily: "VarelaRound",
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      activeColor: Colors.white,
      checkColor: Colors.black,
      value: checkedItems[item],
      onChanged: (bool? value) {
        setState(() {
          checkedItems[item] = value!;
        });
      },
    );
  }
}

// Dummy Cooking Steps Page
class CookingStepsPage extends StatelessWidget {
  final String recipeName;

  const CookingStepsPage({Key? key, required this.recipeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF80A6A4),
      body: SafeArea(
        child: Center(
          child: Text(
            "Cooking steps for $recipeName",
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

void _showBackConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF5E92A8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: const Text(
          "Go Back?",
          style: TextStyle(
            fontFamily: "Chewy",
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        content: const Text(
          "If you go back, you will need to scan ingredients again. Do you want to continue?",
          style: TextStyle(
            fontFamily: "VarelaRound",
            fontSize: 14.0,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog and stay
            },
            child: const Text(
              "Stay",
              style: TextStyle(
                fontFamily: "Chewy",
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LetsCook01()),
              ); // Go back to LetsCook01
            },
            child: const Text(
              "Go Back",
              style: TextStyle(
                fontFamily: "Chewy",
                fontSize: 16.0,
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );
}
