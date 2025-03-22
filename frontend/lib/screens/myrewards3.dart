import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/rewards.dart';
import 'package:frontend/screens/jwtDecodeService.dart'; // Import JWT Service
import 'package:frontend/main.dart';
import 'design.dart';
import 'homepage.dart';
import 'package:http/http.dart' as http;

class MyRewards3Page extends StatefulWidget {
  const MyRewards3Page({super.key});

  @override
  _MyRewards3PageState createState() => _MyRewards3PageState();
}

class _MyRewards3PageState extends State<MyRewards3Page> {
  String? _stickerImageUrl;
  String? _stickerName;
  final JwtService _jwtService = JwtService(); // JWT Service instance

  @override
  void initState() {
    super.initState();
    _fetchRandomSticker(); // Fetch sticker when page loads
  }

  // Fetch a random sticker from the backend
  Future<void> _fetchRandomSticker() async {
    
    // Retrieve the JWT token and user ID
    String? token = await _jwtService.storage.read(key: "jwt_token");
    Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
    int? userID = decodedToken?['id'];

    if (userID == null || token == null) {
      print("User authentication failed.");
      return;
    }

    final String apiUrl = '$URL/api/sticker/random?userID=$userID';

    try {
      print("Fetching random sticker for userID $userID from: $apiUrl");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || (data is List && data.isEmpty) || data['filePath'] == null) {
          print("No stickers left to claim.");
          _showAllStickersClaimedDialog();
        } else {
          print("Fetched sticker details: ${data['filePath']}, ${data['stickerName']}");
          setState(() {
            _stickerImageUrl = data['filePath'];
            _stickerName = data['stickerName'];
          });
        }
      } else if (response.statusCode == 400) {
        print("No stickers left to claim. Showing dialog.");
        _showAllStickersClaimedDialog();
      } else {
        print("Failed to fetch sticker. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching sticker: $e");
    }
  }

  // Show dialog when all stickers are claimed
  void _showAllStickersClaimedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5B98A9),
          title: const Text(
            "Congratulations!",
            style: TextStyle(color: Colors.white, fontFamily: 'Chewy', fontSize: 24),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "You have claimed all the stickers!",
            style: TextStyle(color: Colors.white, fontFamily: 'Chewy', fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StickerCollectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Back to Collection',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Load sticker image from the backend
  Widget _buildBackendImage(String filePath) {
    final String sanitizedFileName = filePath.replaceFirst("assets/stickers/", "");
    final String backendUrl = "$URL/api/stickers/$sanitizedFileName";

    print("Loading sticker from: $backendUrl");

    return Image.network(
      backendUrl,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error loading sticker: $error");
        return Container(
          color: Colors.grey,
          width: 200,
          height: 200,
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Chewy'),
                textAlign: TextAlign.center,
              ),
              const Text(
                'The following has been added to\nyour COOKAstix Collection:',
                style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
                textAlign: TextAlign.center,
              ),
              _stickerImageUrl == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                      children: [
                        _buildBackendImage(_stickerImageUrl!),
                        const SizedBox(height: 10),
                        Text(
                          _stickerName ?? "Unknown Sticker",
                          style: const TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Chewy'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StickerCollectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF336B89),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Back to Collection',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Chewy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
