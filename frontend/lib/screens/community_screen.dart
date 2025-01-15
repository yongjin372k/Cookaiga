import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/design.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B98A9), // Page background color
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Title
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
                      // Handle share a photo logic
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
                  // Horizontal Photos Scroller
                  if (posts.isNotEmpty)
                    SizedBox(
                      height: 200, // Adjust height of the photo section
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                post.imagePath,
                                width: 150, // Width of each photo
                                height: 200, // Height of each photo
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    width: 150,
                                    height: 200,
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
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
                  const SizedBox(height: 24),
                  // Total Photos Shared Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAED8C0), // Light green background
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
                ],
              ),
            ),
    );
  }

}
