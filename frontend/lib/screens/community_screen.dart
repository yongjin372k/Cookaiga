import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart'; // For canvaImage
import 'package:frontend/screens/homepage.dart'; // For HomePage
import 'package:frontend/screens/share_screen.dart'; // For SharePage
import 'package:http/http.dart' as http;

// Model class for a post
class Post {
  final int postID;
  final int userID;
  final String imagePath;
  final String? caption;

  Post({
    required this.postID,
    required this.userID,
    required this.imagePath,
    this.caption,
  });

  // Factory method to create a Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'],
      userID: json['userID'],
      imagePath: json['imagePath'],
      caption: json['caption'],
    );
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Fetch posts from the backend
  Future<void> _fetchPosts() async {
    const String apiUrl = "http://10.0.2.2:8080/api/posts"; // Backend endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = data.map((json) => Post.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print("Failed to fetch posts. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  // Build image widget for both backend and frontend images
  Widget _buildImage(String imagePath) {
    if (!imagePath.startsWith('/assets/posts/')) {
      // Attempt to load a frontend asset
      return Image.asset(
        imagePath,
        width: 180,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading frontend asset: $imagePath. Falling back to backend.");
          final String fileName = imagePath.split('/').last;
          return _buildBackendImage(fileName); // Fallback to backend
        },
      );
    } else {
      // For backend images
      final String fileName = imagePath.replaceFirst('/assets/posts/', '');
      return _buildBackendImage(fileName);
    }
  }

  // Helper method to build an image widget from the backend
  Widget _buildBackendImage(String fileName) {
    final String backendUrl = "http://10.0.2.2:8080/api/files/$fileName";
    print("Fetching backend image: $backendUrl");

    return Image.network(
      backendUrl,
      width: 180,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error loading backend image: $backendUrl");
        return Container(
          color: Colors.grey,
          width: 180,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B98A9),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: canvaImage('back_arrow.png', width: 50, height: 50),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'COOKAiGA Connect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Share a Photo Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SharePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    child: const Text(
                      'share a photo',
                      style: TextStyle(
                        color: Color(0xFF5B98A9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Chewy',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Horizontal synchronized scrolling rows
                  if (posts.isNotEmpty)
                    SizedBox(
                      height: 450,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (posts.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final int firstRowIndex = index * 2;
                          final int secondRowIndex = firstRowIndex + 1;

                          return Column(
                            children: [
                              if (firstRowIndex < posts.length)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildImage(posts[firstRowIndex].imagePath),
                                  ),
                                ),
                              if (secondRowIndex < posts.length)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildImage(posts[secondRowIndex].imagePath),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'No posts yet. Be the first to share!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Chewy',
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Total Photos Shared Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAED8C0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total photos shared by the community:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Chewy',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${posts.length}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Chewy',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Do you know? For every 100 photos shared, \$1 will be donated to SPARKS (Singapore).",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Chewy',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
