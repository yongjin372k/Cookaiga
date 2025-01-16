import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/homepage.dart'; // For navigation to HomePage
import 'package:frontend/screens/design.dart'; // For canvaImage

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Function to upload the image to the backend
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    try {
      // Backend API endpoint
      const String apiUrl = "http://10.0.2.2:8080/api/posts/upload";

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['userID'] = '1' // Replace with actual user ID
        ..files.add(await http.MultipartFile.fromPath(
          'imagePath', // Name of the field for the file in the backend
          _selectedImage!.path,
        ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo shared successfully!")),
        );
        setState(() {
          _selectedImage = null;
        });
      } else {
        print("Failed to share photo. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to share photo.")),
        );
      }
    } catch (e) {
      print("Error uploading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sharing photo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B98A9),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: canvaImage('back_arrow.png', width: 50, height: 50),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Connect me!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Chewy',
            ),
          ),
          const SizedBox(height: 16),
          // Image Container
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFFF6D9A6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedImage == null
                  ? const Center(
                      child: Text(
                        'Tap to upload your photo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontFamily: 'Chewy',
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Disclaimer Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'By uploading a photo, you consent to its use on this platform and agree that it does not contain explicit or inappropriate content. Failure to comply may result in the removal of the photo and potential restrictions on your account.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: 'Chewy',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Share Photo Button
          ElevatedButton(
            onPressed: _uploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF336A84),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            ),
            child: const Text(
              'share my photo',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Chewy',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
