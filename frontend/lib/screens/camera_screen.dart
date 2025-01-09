import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  final String apiUrl = "http://10.0.2.2:8080/api/image-analysis/analyze"; // Base API URL
  final int userId = 1; // Example userID (make this dynamic if needed)

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras(); // Get available cameras
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], // Use the first available camera
        ResolutionPreset.high, // Use high resolution
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

        // Send the captured image to the API
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
        _isCameraInitialized = false; // Stop the camera preview
      });

      // Send the selected image to the API
      await _sendImageToApi(_selectedImage!);
    }
  }

  Future<void> _sendImageToApi(File image) async {
    try {
      // Build the API URL with the userID query parameter
      String urlWithUserId = "$apiUrl?userID=$userId";

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(urlWithUserId));

      // Add the image file to the request with the key 'imageUrl'
      request.files.add(
        await http.MultipartFile.fromPath(
          'imageUrl', // Key expected by the backend
          image.path,
        ),
      );

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Successfully sent image
        final responseBody = await response.stream.bytesToString();
        print("Image successfully sent to the API! Response: $responseBody");

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image successfully analyzed!")),
        );
      } else {
        // Handle API errors
        final responseBody = await response.stream.bytesToString();
        print("Failed to send image. Status Code: ${response.statusCode}");
        print("Error Response: $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      print("Error sending image to the API: $e");

      // Display error message
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
