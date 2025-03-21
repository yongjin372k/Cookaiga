import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/letscook_03.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/jwtDecodeService.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  File? _capturedImage;
  File? _selectedImage;
  bool _isCameraInitialized = false;
  final JwtService _jwtService = JwtService(); // JWT Service for retrieving userID & token

  final String apiUrl = "$URL/api/image-analysis/analyze"; // Base API URL

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile imageFile = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = File(imageFile.path);
        });

        await _sendImageToApi(_capturedImage!);
      } catch (e) {
        print("Error taking picture: $e");
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isCameraInitialized = false;
      });

      await _sendImageToApi(_selectedImage!);
    }
  }

  Future<void> _sendImageToApi(File image) async {
    try {
      // Retrieve the JWT token and user ID
      String? token = await _jwtService.storage.read(key: "jwt_token");
      Map<String, dynamic>? decodedToken = await _jwtService.getDecodedToken();
      int? userID = decodedToken?['id'];

      if (userID == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in. Please log in again.")),
        );
        return;
      }

      // Append userID to the API URL
      String urlWithUserId = "$apiUrl?userID=$userID";

      var request = http.MultipartRequest('POST', Uri.parse(urlWithUserId))
        ..headers['Authorization'] = 'Bearer $token' // Attach JWT token
        ..files.add(await http.MultipartFile.fromPath(
          'imageUrl', // Backend expects this field name
          image.path,
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Image successfully sent to the API!");

        // Fetch the generated recipes from the backend
        final recipeResponse = await http.get(
          Uri.parse('$URL2/api/kitchen-list?userID=$userID'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (recipeResponse.statusCode == 200) {
          final responseData = jsonDecode(recipeResponse.body);
          final List<String> recipes = (responseData['recipes'] as List<dynamic>).cast<String>();

          // Navigate to LetsCook03Content page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LetsCook03Content(recipes: recipes),
            ),
          );
        } else {
          throw Exception('Failed to fetch recipes');
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        print("Failed to send image. Status Code: ${response.statusCode}");
        print("Error Response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      print("Error sending image to the API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending image: $e")),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Camera Preview
          if (_isCameraInitialized)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

          // Translucent overlay for controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Select from gallery button
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _pickImageFromGallery,
                  ),
                  // Take picture button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
