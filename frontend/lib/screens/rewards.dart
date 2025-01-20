import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'design.dart'; // Import for createMaterialColor.
import 'homepage.dart'; // Import the HomePage
import 'myrewards2.dart'; // Import the MyRewards2Page
import 'dart:convert';
import 'package:http/http.dart' as http;

class StickerCollectionPage extends StatefulWidget {
  const StickerCollectionPage({super.key});

  @override
  _StickerCollectionPageState createState() => _StickerCollectionPageState();
}

class _StickerCollectionPageState extends State<StickerCollectionPage> {
  final int _totalStickerSlotsPerPage = 12; // Total slots per page
  final List<Color> _pageColors = [
    const Color(0xFF80A6A4),
    const Color(0xFF8C92AC),
    const Color(0xFFF1BFA1),
  ]; // Page colors for empty slots

  int _currentPage = 1; // Current page number
  List<Map<String, dynamic>> _userStickers = []; // Sticker details
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserStickers(); // Fetch user stickers when the page loads
  }

  // Fetch all sticker IDs redeemed by the user, then fetch their details
  Future<void> _fetchUserStickers() async {
    const int userID = 1; // Replace with the actual user ID
    final String apiUrl = '$URL/api/redemptions/user/$userID';

    try {
      print("Fetching sticker IDs for user $userID from: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode response body as UTF-8
        final List<dynamic> redemptionData = jsonDecode(utf8.decode(response.bodyBytes));
        print("Redemptions response: $redemptionData");

        final stickers = await Future.wait(
          redemptionData.map((redemption) async {
            final stickerID = redemption['stickerID'];
            // Parse the `redeemedAt` field and extract only the date
            final redemptionDate = redemption['redeemedAt'] != null
                ? DateTime.parse(redemption['redeemedAt'])
                    .toLocal()
                    .toIso8601String()
                    .split('T')[0]
                : "Unknown Date";

            final stickerDetails = await _fetchStickerDetails(stickerID);

            if (stickerDetails != null) {
              return {
                ...stickerDetails,
                'redeemedAt': redemptionDate,
              };
            }
            return null;
          }),
        );

        setState(() {
          _userStickers = stickers.whereType<Map<String, dynamic>>().toList();
          _isLoading = false;
        });
      } else {
        print("Failed to fetch sticker IDs. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching stickers for user $userID: $e");
    }
  }

  // Fetch individual sticker details using its ID
  Future<Map<String, dynamic>?> _fetchStickerDetails(int stickerID) async {
    final String stickerApiUrl = '$URL/api/sticker/$stickerID';

    try {
      print("Fetching sticker details for Sticker ID: $stickerID");
      final response = await http.get(Uri.parse(stickerApiUrl));

      if (response.statusCode == 200) {
        // Decode response body as UTF-8
        final Map<String, dynamic> stickerDetails = jsonDecode(utf8.decode(response.bodyBytes));
        print("Response for sticker $stickerID: $stickerDetails");
        return stickerDetails; // Return the full sticker details
      } else {
        print("Failed to fetch sticker $stickerID. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching sticker details for ID $stickerID: $e");
    }

    return null; // Return null if fetch fails
  }

  // Helper method to build an image widget from the backend
  Widget _buildBackendImage(String filePath) {
    // Remove "assets/stickers/" from the filePath if it exists
    final String sanitizedFileName = filePath.replaceFirst("assets/stickers/", "");
    final String backendUrl = "$URL/api/stickers/$sanitizedFileName";

    return Image.network(
      backendUrl,
      width: 180,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey,
          width: 180,
          height: 200,
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  // Show dialog with sticker details
  void _showStickerDetailsDialog(Map<String, dynamic> stickerData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5B98A9),
          title: Text(
            stickerData['stickerName'],
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Chewy',
              fontSize: 26,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBackendImage(stickerData['filePath']),
              const SizedBox(height: 10),
              Text(
                stickerData['stickerDesc'] ?? "No description available.",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Chewy',
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Redeemed on: ${stickerData['redeemedAt']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Chewy',
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
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
    return Theme(
      data: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF4CAF50)), // Create a custom swatch
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B98A9),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Button and Cart Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      child: canvaImage('back_arrow.png', width: 50, height: 50),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyRewards2Page()),
                        );
                      },
                      child: canvaImage('cart_icon.png', width: 70, height: 70),
                    ),
                  ],
                ),
              ),
              // Page Title
              const Text(
                'COOKAstix Collection',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'Chewy',
                ),
              ),
              const SizedBox(height: 20),
              // Sticker Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 stickers per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _totalStickerSlotsPerPage,
                          itemBuilder: (context, index) {
                            final int stickerIndex =
                                ((_currentPage - 1) * _totalStickerSlotsPerPage) + index;

                            if (stickerIndex >= _userStickers.length) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: _pageColors[_currentPage - 1],
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }

                            final stickerData = _userStickers[stickerIndex];

                            return GestureDetector(
                              onTap: () => _showStickerDetailsDialog(stickerData),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _pageColors[_currentPage - 1],
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _buildBackendImage(stickerData['filePath']),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              // Page Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Page',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(width: 20),
                  for (int i = 1; i <= _pageColors.length; i++) // Iterate over available pages
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentPage = i;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == i
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Chewy',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
