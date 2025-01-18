import 'package:flutter/material.dart';
import 'package:frontend/screens/rewards.dart';
import 'package:frontend/main.dart';
import 'design.dart';
import 'homepage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyRewards3Page extends StatefulWidget {
  const MyRewards3Page({super.key});

  @override
  _MyRewards3PageState createState() => _MyRewards3PageState();
}

class _MyRewards3PageState extends State<MyRewards3Page> {
  String? _stickerImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchRandomSticker(); // Fetch the random sticker when the page loads
  }

  // Function to fetch a random sticker image from the backend
  Future<void> _fetchRandomSticker() async {
    const int userID = 1; // Replace with the actual user ID if dynamic
    final String apiUrl = '$URL/api/sticker/random?userID=$userID';

    try {
      print("Fetching random sticker for userID $userID from: $apiUrl");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      // Log the raw response for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the backend returned no stickers
        if (data == null || (data is List && data.isEmpty)) {
          print("No stickers left to claim.");
          _showAllStickersClaimedDialog();
        } else if (data['filePath'] == null) {
          print("Sticker file path is missing in response.");
          _showAllStickersClaimedDialog();
        } else {
          print("Fetched sticker details: ${data['filePath']}");
          setState(() {
            _stickerImageUrl = data['filePath']; // Backend returns a field `filePath`
          });
        }
      } else if (response.statusCode == 400) {
        // Backend indicates there are no stickers left
        print("No stickers left to claim. Showing dialog.");
        _showAllStickersClaimedDialog();
      } else {
        print("Failed to fetch sticker. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching sticker: $e");
    }
  }

  // Helper method to build an image widget from the backend
  Widget _buildBackendImage(String filePath) {
    // Remove "assets/stickers/" from the filePath if it exists
    final String sanitizedFileName = filePath.replaceFirst("assets/stickers/", "");
    final String backendUrl = "$URL/api/stickers/$sanitizedFileName";

    // Debugging logs
    print("Original file path: $filePath");
    print("Sanitized file name (without prefix): $sanitizedFileName");
    print("Constructed backend URL: $backendUrl");

    return Image.network(
      backendUrl,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print("Successfully loaded sticker: $sanitizedFileName");
          return child;
        }
        print("Loading progress for sticker: $sanitizedFileName - "
            "${loadingProgress.expectedTotalBytes != null ? 
                (loadingProgress.cumulativeBytesLoaded / 
                loadingProgress.expectedTotalBytes! * 100).toStringAsFixed(0) : 'Unknown'}%");
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        print("Failed to load sticker: $sanitizedFileName. Error: $error");
        return Container(
          color: Colors.grey,
          width: 200,
          height: 200,
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  // Show dialog when all stickers are claimed
  void _showAllStickersClaimedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog without action
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5B98A9),
          title: const Text(
            "Congratulations!",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Chewy',
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You have claimed all the stickers!",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Chewy',
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StickerCollectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Back to Collection',
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
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9), // Background color
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Congratulations Header
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Chewy',
                ),
                textAlign: TextAlign.center,
              ),
              // Subheader
              const Text(
                'The following has been added to\nyour COOKAstix Collection:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Chewy',
                ),
                textAlign: TextAlign.center,
              ),
              // Sticker Image or Loading Indicator
              _stickerImageUrl == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _buildBackendImage(_stickerImageUrl!),
              // Back to Collection Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StickerCollectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Back to Collection',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Chewy',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
