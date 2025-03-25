import 'dart:io';
import 'package:flutter/material.dart';
import '../models/data.dart';
import 'page_view_my_kitchen_01.dart';
import 'page_view_my_kitchen_04.dart';
import '../controller/audio_controller.dart';

class ViewMyKitchen03 extends StatefulWidget {
  final String imagePath; // Captured image from ViewMyKitchen02
  final List<String> detectedIngredients; // Ingredients extracted from the image

  const ViewMyKitchen03({
    Key? key,
    required this.imagePath,
    required this.detectedIngredients,
  }) : super(key: key);

  @override
  _ViewMyKitchen03State createState() => _ViewMyKitchen03State();
}

class _ViewMyKitchen03State extends State<ViewMyKitchen03> {
  final Set<String> _selectedIngredients = {}; // Store user-selected ingredients

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF336B89),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(
            "Your items have been added to your kitchen inventory!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Chewy",
              fontSize: 22.0,
              color: Colors.white,
            ),
          ),
          // content: const Text(
          //   "Your ingredients have been successfully added to your kitchen inventory.",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontFamily: "VarelaRound",
          //     fontSize: 16.0,
          //     color: Colors.white,
          //   ),
          // ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ViewMyKitchen01()),
                );
              },
              child: const Text(
                "Go Back",
                style: TextStyle(
                  fontFamily: "VarelaRound",
                  fontSize: 16.0, 
                  color: Color(0xFFAED8C0),
                  fontWeight: FontWeight.w600, 
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ViewMyKitchen04()),
                );
              },
              child: const Text(
                "Browse Inventory",
                style: TextStyle(
                  fontFamily: "VarelaRound",
                  fontSize: 16.0, 
                  color: Color(0xFFF1BFA1),
                  fontWeight: FontWeight.w600, 
                ),
              ),
            ),
          ],
        );
      },
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
              'assets/background/page_view_my_kitchen_03.png',
              fit: BoxFit.cover,
            ),
          ),

          // Safe Area for UI
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
                // -- END of back button --

                const SizedBox(height: 20),

                // -- START of Title --
                const Text(
                  "Review Your Ingredients",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Chewy",
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // -- Captured Image Display --
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      File(widget.imagePath),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -- List of Detected Ingredients with Checkboxes --
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.detectedIngredients.length,
                    itemBuilder: (context, index) {
                      String ingredient = widget.detectedIngredients[index];
                      return CheckboxListTile(
                        title: Text(
                          ingredient,
                          style: const TextStyle(
                            fontFamily: "VarelaRound",
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        value: _selectedIngredients.contains(ingredient),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedIngredients.add(ingredient);
                            } else {
                              _selectedIngredients.remove(ingredient);
                            }
                          });
                        },
                        activeColor: Colors.orangeAccent,
                        checkColor: Colors.white,
                        tileColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // -- Confirm Button to Update Kitchen Inventory --
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      myKitchen.addAll(
                        _selectedIngredients.map((ingredient) => {
                          "name": ingredient,
                          "expiryDate": "Unknown", // Default value, you can change this
                          "quantity": 1 // Default quantity, you can change this
                        })
                      );
                    });
                    _showConfirmationDialog(context); // Show success popup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF336B89),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Confirm & Update Kitchen",
                    style: TextStyle(
                      fontFamily: "Chewy",
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
