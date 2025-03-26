import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/design.dart'; // For canvaImage
import 'package:frontend/screens/homepage.dart'; // For HomePage
import 'package:frontend/screens/share_screen.dart'; // For SharePage
import 'package:http/http.dart' as http;
import 'dart:async';

// Model class for a post
class Post {
  final int postID;
  final int userID;
  final String imagePath;
  final String? caption;
  int likes;                  // Not in Post
  int comments;
  final String username;
  final String timestamp;     // Not in Post

  Post({
    required this.postID,
    required this.userID,
    required this.imagePath,
    this.caption,
    this.likes = 0,           // Not in Post
    this.comments = 0,
    required this.username,
    required this.timestamp,  // Not in Post
  });

  // Factory method to create a Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'],
      userID: json['userID'],
      imagePath: json['imagePath'],
      caption: json['caption'],
      likes: json['likes'] ?? 0,                    // Not in Post
      comments: json['comments'] ?? 0,
      username: json['username'] ?? 'User',
      timestamp: json['timestamp'] ?? 'Just now',   // Not in Post
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
    final String apiUrl = "$URL/api/posts"; // Backend endpoint

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
        width: double.infinity,
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
    final String backendUrl = "$URL/api/files/$fileName";
    print("Fetching backend image: $backendUrl");

    return Image.network(
      backendUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error loading backend image: $backendUrl");
        return Container(
          color: Colors.grey,
          width: double.infinity,
          height: 200,
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  // Method to handle like button press
  void _handleLike(Post post) {
    setState(() {
      post.likes += 1;
    });
  }

  // Method to handle comment button press
  void _handleComment(Post post) {
    // Navigate to comment section or open a dialog
    print("Navigate to comments for post ${post.postID}");
  }

  // Method to build each post item
  Widget _buildPostItem(Post post) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    post.username[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontFamily: "Chewy",
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      post.timestamp,
                      style: const TextStyle(
                        fontFamily: "VarelaRound",
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Post Image
          _buildImage(post.imagePath),

          // Post Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post.caption!,
                style: const TextStyle(
                  fontFamily: "VarelaRound",
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
            ),

          // Like & Comment Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () => _handleLike(post),
                    ),
                    Text(
                      "${post.likes} Likes",
                      style: const TextStyle(
                        fontFamily: "VarelaRound",
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.blue),
                      onPressed: () => _handleComment(post),
                    ),
                    Text(
                      "${post.comments} Comments",
                      style: const TextStyle(
                        fontFamily: "VarelaRound",
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: canvaImage('back_arrow.png', width: 50, height: 50),
        ),
        title: const Text(
          'Hello, My Community!',
          style: TextStyle(
            fontFamily: "Chewy",
            fontSize: 22.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SharePage()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : posts.isEmpty
              ? const Center(
                  child: Text(
                    'No posts yet. Be the first to share!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Chewy',
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostItem(post);
                  },
                ),
    );
  }
}
