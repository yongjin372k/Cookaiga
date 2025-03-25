import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../controller/audio_controller.dart';
import 'page_lets_cook_03.dart';

final Logger logger = Logger();

class LetsCook02 extends StatefulWidget {
  const LetsCook02({Key? key}) : super(key: key);

  @override
  _LetsCook02State createState() => _LetsCook02State();
}

class _LetsCook02State extends State<LetsCook02> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller with the first available camera.
    availableCameras().then((cameras) {
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture your ingredients!')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            // Make sure the camera is initialized
            await _initializeControllerFuture;
            // Take the picture
            final image = await _controller.takePicture();

            // TODO: Perform any image processing or ML inference here
            
            if (!isMusicOn) {
              await toggleMusic(); // Start music using global controller.
            }
            // Navigate to LetsCook03, passing the image path
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LetsCook03(imagePath: image.path),
              ),
            );
          } catch (e, stackTrace) {
            logger.e("Error capturing image", error: e, stackTrace: stackTrace);
          }
        },
      ),
    );
  }
}
