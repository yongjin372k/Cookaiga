import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'transition.dart';
import 'package:frontend/screens/overview_recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

class MyKitchen03Content extends StatefulWidget {
  @override
  _MyKitchen03ContentState createState() => _MyKitchen03ContentState();
}

class _MyKitchen03ContentState extends State<MyKitchen03Content> {
  // Dummy data for the inventory
  List<Map<String, dynamic>> inventory = []; // Inventory data from the backend

  final String baseUrl = "$URL/api/ingredients"; // Replace with your backend URL

  @override
  void initState() {
    super.initState();
    fetchInventory(); // Fetch data when the widget initializes
  }

  // Fetch inventory data from the backend
  Future<void> fetchInventory() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          inventory = data.map((item) => {
            'id': item['id'], // Include the ID for future edits/deletes
            'item': item['item'],
            'quantityWithUnit': item['quantityWithUnit'],
            'expiry': item['expiry'],
          }).toList();
        });
      } else {
        print("Failed to fetch inventory: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching inventory: $error");
    }
  }

  // Add a new inventory item
  Future<void> addInventoryItem(String itemName, String quantity, String unit, String expiryDate) async {
    final newItem = {
      'item': itemName,
      'quantityWithUnit': '$quantity $unit',
      'expiry': expiryDate,
    };
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem),
      );
      if (response.statusCode == 200) {
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
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedItem),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  // Function to display the Edit dialog
  void showEditDialog(BuildContext context, Map<String, dynamic> item) {
    String itemName = item['item'];
    String quantity = item['quantityWithUnit'].split(' ')[0];
    String unit = item['quantityWithUnit'].split(' ')[1].toLowerCase(); // Extract unit (normalize case)
    String expiryDate = item['expiry']; // Extract expiry date
    
    // Define units as singular/plural friendly
    List<String> units = ['piece', 'gram', 'liter', 'cup', 'other'];

    // Normalize the unit to singular (e.g., "grams" -> "gram")
    if (unit.endsWith('s')) unit = unit.substring(0, unit.length - 1);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: createMaterialColor(const Color(0xFFF9E0D2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Edit Item',
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
                  value: unit, // Match normalized unit (singular form)
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) => unit = value!,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                  controller: TextEditingController(text: item['expiry']),
                  onChanged: (value) => item['expiry'] = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Chewy'),
              ),
            ),
            TextButton(
              onPressed: () {
                // Prepare the updated item details
                final updatedItem = {
                  'item': itemName,
                  'quantityWithUnit': '$quantity ${unit.endsWith('s') ? unit : '${unit}s'}',
                  'expiry': expiryDate,
                };

                // Call the update method
                updateInventoryItem(item['id'], updatedItem);

                // Close the dialog
                Navigator.pop(context);
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
      final dateA = DateTime.tryParse(a['expiry']) ?? DateTime.now();
      final dateB = DateTime.tryParse(b['expiry']) ?? DateTime.now();
      return dateA.compareTo(dateB); // Ascending order
    });

    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF80A6A4)),
      body: Stack(
        children: [
          // Top-left Positioned Back Arrow
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(fadeTransition(const MyKitchen01Content()));
              },
              child: canvaImage('back_arrow.png', width: 50, height: 50),
            ),
          ),

          // Positioned Add Button in Top-Right
          Positioned(
            top: 130,
            right: 15,
            child: GestureDetector(
              onTap: () {
                // Add button functionality here
                print('Add item');
                showAddDialog(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: createMaterialColor(const Color(0xFFF1BFA1)),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.black),
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
                  child: canvaImage('browse_inventory.png', width: 120, height: 120),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Container(
                          height: 100, // Set the height of the list item
                          decoration: BoxDecoration(
                            color: createMaterialColor(const Color(0xFFF1BFA1)),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
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
                                  color: createMaterialColor(const Color(0xFFE0E0E0)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    item['item'][0].toUpperCase(), // Initial Character
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Chewy',
                                    ),
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
                                      // Item Name
                                      Text(
                                        item['item'],
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: 'Chewy',
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      // Quantity
                                      Row(
                                        children: [
                                          const Icon(Icons.shopping_cart, size: 16, color: Colors.black),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Qty: ${item['quantityWithUnit']}',
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
                                            'Expiry: ${item['expiry']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
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
                                    print('View action selected for ${item['item']}');
                                    showViewDialog(context, item);
                                  } else if (value == 'edit') {
                                    print('Edit action selected for ${item['item']}');
                                    showEditDialog(context, item);
                                  }
                                },
                                icon: const Icon(
                                  Icons.more_vert, // Three-dot icon
                                  color: Colors.black, // Icon color
                                ),
                                color: createMaterialColor(const Color(0xFFF9E0D2)), // Popup background color
                                elevation: 6, // Add shadow for better visibility
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0), // Rounded corners
                                ),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.visibility,
                                          color: Color(0xFF80A6A4), // Custom icon color
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Chewy', // Match the app's font
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.edit,
                                          color: Color(0xFF80A6A4), // Custom icon color
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Chewy', // Match the app's font
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
