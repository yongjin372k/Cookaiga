import 'package:flutter/material.dart';
import '../models/data.dart';
import 'page_view_my_kitchen_01.dart';
import '../controller/audio_controller.dart';

class ViewMyKitchen04 extends StatefulWidget {
  const ViewMyKitchen04({Key? key}) : super(key: key);

  @override
  _ViewMyKitchen04State createState() => _ViewMyKitchen04State();
}

class _ViewMyKitchen04State extends State<ViewMyKitchen04> {
  // Function to show edit ingredient dialog
  void _editIngredient(int index) {
    TextEditingController nameController =
        TextEditingController(text: myKitchen[index]["name"]);
    TextEditingController expiryController =
        TextEditingController(text: myKitchen[index]["expiryDate"]);
    TextEditingController quantityController =
        TextEditingController(text: myKitchen[index]["quantity"].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(
            "Edit Ingredient",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Ingredient Name", nameController),
              const SizedBox(height: 8),
              _buildTextField("Expiry Date (DD/MM/YYYY)", expiryController),
              const SizedBox(height: 8),
              _buildTextField("Stock Quantity", quantityController, isNumber: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close without saving
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  myKitchen[index]["name"] = nameController.text;
                  myKitchen[index]["expiryDate"] = expiryController.text;
                  myKitchen[index]["quantity"] = int.tryParse(quantityController.text) ?? 1;
                });
                Navigator.pop(context); // Save changes and close
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 16.0, color: Colors.orangeAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to delete ingredient with confirmation
  void _deleteIngredient(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(
            "Delete Ingredient?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to remove this ingredient from your kitchen?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "VarelaRound", fontSize: 16.0, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  myKitchen.removeAt(index);
                });
                Navigator.pop(context); // Remove ingredient and close dialog
              },
              child: const Text(
                "Delete",
                style: TextStyle(fontSize: 16.0, color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addIngredient() {
    TextEditingController nameController = TextEditingController();
    TextEditingController expiryController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(
            "Add Ingredient",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Ingredient Name", nameController),
              const SizedBox(height: 8),
              _buildTextField("Expiry Date (DD/MM/YYYY)", expiryController),
              const SizedBox(height: 8),
              _buildTextField("Stock Quantity", quantityController, isNumber: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                  setState(() {
                    myKitchen.add({
                      "name": nameController.text,
                      "expiryDate": expiryController.text.isNotEmpty ? expiryController.text : "Unknown",
                      "quantity": int.tryParse(quantityController.text) ?? 1,
                    });
                  });
                  Navigator.pop(context); // Save and close dialog
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(fontSize: 16.0, color: Colors.orangeAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to build text fields inside edit dialog
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
              'assets/background/page_view_my_kitchen_04.png', // Ensure path is correct
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // -- START of back button --
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Arrow
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => ViewMyKitchen01()),
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

                      Row(
                        children: [
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

                          const SizedBox(width: 10), // Spacing

                          // "+" Button for Adding Ingredients
                          RawMaterialButton(
                            onPressed: _addIngredient, // Calls the function to add an ingredient
                            fillColor: const Color(0xFF5E92A8),
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 40,
                            ),
                            shape: const CircleBorder(),
                            child: const Icon(Icons.add, color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // -- END of back button --

                // -- START of Title --
                const Text(
                  "Your Kitchen Inventory",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Chewy",
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // -- START of Ingredient List --
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: myKitchen.length,
                    itemBuilder: (context, index) {
                      final ingredient = myKitchen[index];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Image.asset(
                            _getIngredientIcon(ingredient["name"]), // Get correct icon
                            width: 40,
                            height: 40,
                          ),
                          title: Text(
                            ingredient["name"],
                            style: const TextStyle(
                              fontFamily: "Chewy",
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Expiry: ${ingredient["expiryDate"]}  |  Qty: ${ingredient["quantity"]}",
                            style: const TextStyle(
                              fontFamily: "VarelaRound",
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editIngredient(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteIngredient(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // -- END of Ingredient List --
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _getIngredientIcon(String ingredientName) {
  // Define a map for ingredient names and their corresponding icons
  Map<String, String> ingredientIcons = {
    "Apple": "assets/cooking_icons/apple.png",
    "Carrot": "assets/cooking_icons/carrot.png",
    "Chicken": "assets/cooking_icons/chicken.png",
    "Tomato": "assets/cooking_icons/tomato.png",
    "Onion": "assets/cooking_icons/onion.png",
    "Potato": "assets/cooking_icons/potato.png",
    "Broccoli": "assets/cooking_icons/broccoli.png",
    "Garlic": "assets/cooking_icons/garlic.png",
    "Rice": "assets/cooking_icons/rice.png",
    "Cheese": "assets/cooking_icons/cheese.png",
    "Milk": "assets/cooking_icons/milk.png",
    "Egg": "assets/cooking_icons/egg.png",
  };

  // Return the matching icon or default icon if not found
  return ingredientIcons[ingredientName] ?? "assets/cooking_icons/ingredient_icon.png";
}
