import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/audio_controller.dart';
import 'package:frontend/screens/letscook_03.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'transition.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'package:frontend/screens/jwtDecodeService.dart'; // Import JWT Service

class MyKitchen03Content extends StatefulWidget {
  @override
  _MyKitchen03ContentState createState() => _MyKitchen03ContentState();
}

class _MyKitchen03ContentState extends State<MyKitchen03Content> {
  // Dummy data for the inventory
  List<Map<String, dynamic>> inventory = []; // Inventory data from the backend
  final JwtService _jwtService = JwtService(); // JWT Service instance
  bool _isEditingDialogs = false;

  //final String baseUrl = "$URL/api/ingredients?userID=1"; // Replace with your backend URL

  @override
  void initState() {
    super.initState();
    fetchInventory(); // Fetch data when the widget initializes
  }

  // Fetch inventory data from the backend
  Future<void> fetchInventory() async {
    if (_isEditingDialogs) {
      print("🛑 Skipping fetchInventory: Dialogs already running.");
      return;
    }
    try {

      String? token = await _jwtService.storage.read(key: "jwt_token");
      Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
      int? userID = decodedToken?['id'];

      if (userID == null || token == null) {
        print("User not authenticated.");
        return;
      }

      final String baseUrl = "$URL/api/ingredients?userID=$userID";

      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        setState(() {
          inventory = data.map((item) {
            return {
              'id': item['id'],
              'item': item['item'],
              'quantityWithUnit': item['quantityWithUnit'] ?? '', // Default to empty
              'expiry': item['expiry'] ?? '', // Default to empty
            };
          }).toList();
        });

        // 🔥 Step 1: Find ingredients that need editing
        List<Map<String, dynamic>> ingredientsToEdit = inventory.where((item) {
          return item['quantityWithUnit'].isEmpty || item['expiry'].isEmpty;
        }).toList();

        // 🔥 Step 2: Open Edit Dialog for each ingredient with missing fields
        if (ingredientsToEdit.isNotEmpty) {
          _isEditingDialogs = true;
          Future.delayed(Duration(milliseconds: 500), () {
            _openEditDialogs(ingredientsToEdit);
          });
        }
      } else {
        print("Failed to fetch inventory: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching inventory: $error");
    }
  }

  void _openEditDialogs(List<Map<String, dynamic>> ingredientsToEdit) {
    if (ingredientsToEdit.isEmpty) return;

    final seenNames = <String>{};
    final uniqueToEdit = <Map<String, dynamic>>[];

    for (var item in ingredientsToEdit) {
      final name = item['item'].toLowerCase().trim();
      if (!seenNames.contains(name)) {
        seenNames.add(name);
        uniqueToEdit.add(item);
      }
    }

    print("🛠️ Unique items needing edit: ${uniqueToEdit.length}");

    int currentIndex = 0;

    void showNextDialog() {
      if (currentIndex >= uniqueToEdit.length) {
        print("✅ All edit dialogs completed.");
        _isEditingDialogs = false;

        // ✅ Fetch fresh data after edits complete
        Future.delayed(Duration(milliseconds: 300), () {
          fetchInventory();  // Re-pull inventory to reflect changes
        });

        return;
      }

      final item = uniqueToEdit[currentIndex];
      print("📝 Editing: ${item['item']} (${currentIndex + 1}/${uniqueToEdit.length})");

      // Use Future.microtask to delay and avoid double show
      Future.microtask(() {
        showEditDialog(context, item, onDialogClose: () {
          currentIndex++;
          showNextDialog();
        });
      });
    }

    showNextDialog();
  }



  // Add a new inventory item
  Future<void> addInventoryItem(String itemName, String quantity, String unit, String expiryDate) async {

    String? token = await _jwtService.storage.read(key: "jwt_token");
      Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
      int? userID = decodedToken?['id'];

      if (userID == null || token == null) {
        print("User not authenticated.");
        return;
      }

    final String baseUrl = "$URL/api/ingredients?userID=$userID";
    
    final newItem = {
      'item': itemName,
      'quantityWithUnit': '$quantity $unit',
      'expiry': expiryDate,
      'userID': userID, // Static userId set to 1
    };
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json",
                  'Authorization': 'Bearer $token',},
        body: jsonEncode(newItem),
      );
      if (response.statusCode == 200) {
        print("Successfully added item:");
        print("Item: $itemName");
        print("Quantity: $quantity $unit");
        print("Expiry Date: $expiryDate");
        fetchInventory(); // Refresh the list after adding
      } else {
        print("Failed to add item: ${response.statusCode}");
      }
    } catch (error) {
      print("Error adding item: $error");
    }
  }

  // Update an existing inventory item
  Future<void> updateInventoryItem(int id, Map<String, dynamic> updatedItem) async {
    try {

      // JWT token decoding
      String? token = await _jwtService.storage.read(key: "jwt_token");
      Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
      int? userID = decodedToken?['id'];

      if (userID == null || token == null) {
        print("User not authenticated.");
        return;
      }

      // Call the backend API to update the ingredient
      final response = await http.post(
        Uri.parse("$URL/api/ingredients/update/$id?userID=$userID"), // Updated URL with POST
        headers: {"Content-Type": "application/json",
                  'Authorization': 'Bearer $token',},
        body: jsonEncode(updatedItem), // Send updated fields
      );

      if (response.statusCode == 200) {
        fetchInventory(); // Refresh the list after updating
      } else {
        print("Failed to update item: ${response.statusCode}");
      }
    } catch (error) {
      print("Error updating item: $error");
    }
  }

  // Delete an inventory item
  Future<void> deleteInventoryItem(int id) async {
    try {

      // JWT token decoding
      String? token = await _jwtService.storage.read(key: "jwt_token");
      Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
      int? userID = decodedToken?['id'];

      if (userID == null || token == null) {
        print("User not authenticated.");
        return;
      }
      final String baseUrl = "$URL/api/ingredients?userID=$userID";

      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode == 204) {
        fetchInventory(); // Refresh the list after deletion
      } else {
        print("Failed to delete item: ${response.statusCode}");
      }
    } catch (error) {
      print("Error deleting item: $error");
    }
  }

  // Function to generate recipes based on the selected ingredient
  Future<void> generateRecipes(BuildContext context, String ingredient) async {
    print("Generate Recipes for: $ingredient");

    try {
      final response = await http.post(
        Uri.parse('$URL2/generate-recipe-from-ingredient'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ingredient": ingredient}),
      );

      print("Ingredient Sent: $ingredient");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Response Data: ${response.body}");

        // Handle response as a list
        if (responseData is List) {
          final List<String> recipes = responseData.cast<String>();
          print("Generated Recipes: $recipes");

          // Use the root context to ensure navigation works
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close the dialog first
          }

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LetsCook03Content(recipes: recipes),
              ),
            );
          }
        } else {
          print("Unexpected response format: ${responseData.runtimeType}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unexpected response format for recipes")),
          );
        }
      } else {
        print("Failed to generate recipes: ${response.body}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error generating recipes: ${response.reasonPhrase}")),
          );
        }
      }
    } catch (e) {
      print("Error generating recipes: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating recipes: $e")),
        );
      }
    }
  }


  /// Helper function to format quantity with singular/plural unit
  String formatQuantityWithUnit(String quantity, String unit) {
    int qty = int.tryParse(quantity) ?? 0;
    // If quantity is 1, use the singular form
    if (qty == 1) {
      unit = unit.endsWith('s') ? unit.substring(0, unit.length - 1) : unit;
    } else {
      // If quantity > 1, ensure the unit is plural
      if (!unit.endsWith('s') && unit != 'pieces') unit += 's';
    }
    return '$quantity $unit';
  }

  // Function to display the Add dialog
  void showAddDialog(BuildContext context) {
    String itemName = '';
    String quantity = '';
    String unit = ''; // Default unit
    String expiryDate = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: createMaterialColor(const Color(0xFFF9E0D2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Add Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Chewy',
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name of Item',
                    labelStyle: TextStyle(fontFamily: 'Chewy'),
                  ),
                  onChanged: (value) => itemName = value,
                ),
                const SizedBox(height: 10),
                // Quantity field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(fontFamily: 'Chewy'),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = value,
                ),
                const SizedBox(height: 10),
                // Unit dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    labelStyle: TextStyle(fontFamily: 'Chewy'),
                  ),
                  value: unit.isEmpty ? null : unit,
                  items: ['pieces', 'grams', 'liters', 'cups', 'others']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) => unit = value!,
                ),
                const SizedBox(height: 10),
                // Expiry Date field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    labelStyle: TextStyle(fontFamily: 'Chewy'),
                    hintText: 'YYYY-MM-DD', // Add a hint for the format
                  ),
                  onChanged: (value) => expiryDate = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Chewy')),
            ),
            TextButton(
              onPressed: () {
                addInventoryItem(itemName, quantity, unit, expiryDate);
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(fontFamily: 'Chewy')),
            ),
          ],
        );
      },
    );
  }

  // Function to display the View dialog
  void showViewDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: createMaterialColor(const Color(0xFFF9E0D2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            item['item'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Chewy',
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity: ${item['quantityWithUnit']}',
                  style: const TextStyle(fontFamily: 'Chewy')),
              const SizedBox(height: 10),
              Text('Expiry Date: ${item['expiry']}',
                  style: const TextStyle(fontFamily: 'Chewy')),
            ],
          ),
          actions: [
            // Generate Recipes Button
            TextButton(
              onPressed: () {
                generateRecipes(context, item['item']); // Generate recipes
              },
              child: const Text(
                'Generate Recipes',
                style: TextStyle(fontFamily: 'Chewy'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text(
                'Close',
                style: TextStyle(fontFamily: 'Chewy'),
              ),
            ),
          ],
        );
      },
    );
  }


  void showEditDialog(BuildContext context, Map<String, dynamic> item, {VoidCallback? onDialogClose}) {
    String itemName = item['item'] ?? "";
    List<String> quantityUnitParts = (item['quantityWithUnit'] ?? "").split(' ');
    String quantity = quantityUnitParts.isNotEmpty ? quantityUnitParts[0] : "0";
    String unit = quantityUnitParts.length > 1 ? quantityUnitParts[1].toLowerCase() : "other";
    String expiryDate = item['expiry'] ?? "";

    List<String> units = ['piece', 'gram', 'liter', 'cup', 'other'];

    if (unit.endsWith('s') && unit != 'pieces') {
      unit = unit.substring(0, unit.length - 1);
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental closure
      builder: (context) {
        return AlertDialog(
          backgroundColor: createMaterialColor(const Color(0xFFF9E0D2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'New Item',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Chewy',
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name of Item'),
                  controller: TextEditingController(text: itemName),
                  onChanged: (value) => itemName = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: quantity),
                  onChanged: (value) => quantity = value,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Unit'),
                  value: units.contains(unit) ? unit : null,
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        unit = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                  controller: TextEditingController(text: expiryDate),
                  onChanged: (value) => expiryDate = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onDialogClose != null) {
                  onDialogClose();
                }
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Chewy'),
              ),
            ),
            TextButton(
              onPressed: () {
                final updatedItem = {
                  'item': itemName,
                  'quantityWithUnit': '$quantity ${unit.endsWith('s') ? unit : '${unit}s'}',
                  'expiry': expiryDate,
                };

                updateInventoryItem(item['id'], updatedItem).then((_) {
                  if (onDialogClose != null) {
                    onDialogClose();
                  }
                  Navigator.pop(context);
                });
              },
              child: const Text(
                'Save',
                style: TextStyle(fontFamily: 'Chewy'),
              ),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {

    // Sort inventory by expiry date
    inventory.sort((a, b) {
      // Safely handle null or invalid expiry values
      final dateA = a['expiry'] != null ? DateTime.tryParse(a['expiry']) : null;
      final dateB = b['expiry'] != null ? DateTime.tryParse(b['expiry']) : null;

      // Use a fallback if the date is null
      final fallbackDateA = dateA ?? DateTime(2100, 1, 1); // Future date as fallback
      final fallbackDateB = dateB ?? DateTime(2100, 1, 1);

      return fallbackDateA.compareTo(fallbackDateB); // Ascending order
    });


    return Scaffold(
      body: Stack(
        children: [
          // Top-left Positioned Back Arrow
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
                // Back Arrow
                RawMaterialButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyKitchen01Content()),
                    );
                  },
                  fillColor: const Color(0xFF4A90A4),
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
                  fillColor: const Color(0xFF4A90A4),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  shape: const CircleBorder(),
                  child: Image.asset(
                    isMusicOn ? 'assets/buttons/sound_on_white.png' : 'assets/buttons/sound_off_white.png',
                    width: 25,
                    height: 25,
                  ),
                ),
              ],
            ),
          ),

          // Positioned Add Button in Top-Right
          Positioned(
            top: 130,
            right: 15,
            child: RawMaterialButton(
              onPressed: () {
                print('Add item');
                showAddDialog(context);
              },
              fillColor: const Color(0xFF4A90A4),
              constraints: const BoxConstraints.tightFor(
                width: 40,
                height: 40,
              ),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),

          // Main Content with "browse inventory" logo and inventory list
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                // Browse Inventory Logo
                Center(
                  child: canvaImage('browse_inventory.png', width: 125, height: 125),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: inventory.isEmpty
                    ? const Center(
                        child: Text(
                          "No ingredients available",
                          style: TextStyle(
                            fontSize: 23,
                            fontFamily: 'Chewy',
                            color: Colors.black,
                            height: -3,
                          ),
                        ),
                      )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];

                    // Parse the expiry date and get today's date
                    final today = DateTime.now();
                    final expiryDate = item['expiry'].isNotEmpty
                        ? DateTime.tryParse(item['expiry'])
                        : null;

                    // Check if the item requires editing (e.g., missing quantity or expiry)
                    final requiresEditing = item['quantityWithUnit'].isEmpty || item['expiry'].isEmpty;

                    // Check if the item is expiring today
                    final isExpiringToday = expiryDate != null &&
                        expiryDate.year == today.year &&
                        expiryDate.month == today.month &&
                        expiryDate.day == today.day;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        height: 100, // Set the height of the list item
                        decoration: BoxDecoration(
                          color: createMaterialColor(const Color(0xFFFFF7F0)),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Circular Container with Initial Character
                            Container(
                              width: 70,
                              height: 70,
                              margin: const EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: createMaterialColor(const Color(0xFFFFF7F0)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/cooking_icons/${item['item'].toLowerCase().replaceAll(' ', '_')}.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback if image doesn't exist
                                    return Text(
                                      item['item']?.isNotEmpty == true ? item['item'][0].toUpperCase() : "?",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Chewy',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Item Details Section
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                                  crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
                                  children: [
                                    // Item Name with Alert Icon if Editing or Expiry Warning
                                    Row(
                                      children: [
                                        Text(
                                          item['item'],
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Chewy',
                                          ),
                                        ),
                                        if (requiresEditing) // For missing fields
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.report_problem, // Icon for missing fields
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        if (isExpiringToday) // For expiry today
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.hourglass_bottom, // Icon for expiry today
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    // Quantity
                                    Row(
                                      children: [
                                        const Icon(Icons.shopping_cart, size: 16, color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Qty: ${item['quantityWithUnit'].isEmpty ? 'N/A' : item['quantityWithUnit']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: 'Chewy',
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Expiry
                                    Row(
                                      children: [
                                        const Icon(Icons.timer, size: 16, color: Colors.black),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Expiry: ${item['expiry'].isEmpty ? 'N/A' : item['expiry']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isExpiringToday ? Colors.red : Colors.black,
                                            fontFamily: 'Chewy',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Popup Menu
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'view') {
                                  showViewDialog(context, item);
                                } else if (value == 'edit') {
                                  showEditDialog(context, item);
                                }
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.black,
                              ),
                              color: const Color(0xFFFFF0E6), // Soft peach background
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.visibility, color: Color(0xFFDECBB7), size: 20), // Soft beige icon
                                      SizedBox(width: 10),
                                      Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Chewy',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: const [
                                      Icon(Icons.edit, color: Color(0xFFDECBB7), size: 20), // Muted mint icon
                                      SizedBox(width: 10),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Chewy',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom Spacer to Prevent List from Touching Phone's Edge
              const SizedBox(height: 20.0), // Adjust the height to your liking
              ],
            ),
          ),
        ],
      ),
    );
  }
}
