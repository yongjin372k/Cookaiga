import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'page_home.dart';

class HelloMyCommunity02 extends StatefulWidget {
  const HelloMyCommunity02({Key? key}) : super(key: key);

  @override
  _HelloMyCommunity02State createState() => _HelloMyCommunity02State();
}

class _HelloMyCommunity02State extends State<HelloMyCommunity02> {
  final List<Map<String, dynamic>> communityPosts = [
    {
      "postID": 1,
      "username": "Alice",
      "image": "assets/posts/sample post 01.jpg",
      "caption": "Winnie and I just made our first bento meal with veggies, tofu, and chicken! Our first experience using COOKAiGA!🍱",
      "timestamp": "2 hours ago",
      "likes": 12,
      "comments": 4
    },
    {
      "postID": 2,
      "username": "David",
      "image": "assets/posts/sample post 02.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 3,
      "username": "Sophia",
      "image": "assets/posts/sample post 03.jpg",
      "caption": "Made my first homemade salad bowl! 🥗",
      "timestamp": "1 day ago",
      "likes": 30,
      "comments": 10
    },
    {
      "postID": 4,
      "username": "David",
      "image": "assets/posts/sample post 04.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 5,
      "username": "David",
      "image": "assets/posts/sample post 05.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 6,
      "username": "David",
      "image": "assets/posts/sample post 06.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 7,
      "username": "David",
      "image": "assets/posts/sample post 07.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 8,
      "username": "David",
      "image": "assets/posts/sample post 08.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 9,
      "username": "David",
      "image": "assets/posts/sample post 09.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
    {
      "postID": 10,
      "username": "David",
      "image": "assets/posts/sample post 10.jpg",
      "caption": "With avocado, bread, and eggs left in the kitchen, we've made our first avocado toast with scrambled eggs today! 🥑🍳",
      "timestamp": "5 hours ago",
      "likes": 20,
      "comments": 6
    },
  ];
  int _postCounter = 1; // Temporary default, will be updated in initState()

  @override
  void initState() {
    super.initState();
    _postCounter = _getNextPostID();
  }

  int _getNextPostID() {
    if (communityPosts.isNotEmpty) {
      return communityPosts.map((post) => post["postID"] as int).reduce((a, b) => a > b ? a : b) + 1;
    }
    return 1;
  }

  void _createNewPost(BuildContext context) {
    int cookedDishes = 4; // Replace with actual value
    int existingPosts = communityPosts.length; // Count current posts

    if (existingPosts >= cookedDishes) {
      // If the user has reached their max post limit, show an alert
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF5E92A8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            title: const Text(
              "Post Limit Reached!",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
            ),
            content: const Text(
              "You can only post as many times as you've cooked! Keep cooking to share more.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "VarelaRound", fontSize: 16.0, color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text("OK", style: TextStyle(fontSize: 16.0, color: Colors.white)),
              ),
            ],
          );
        },
      );
      return; // Stop execution if the limit is reached
    }

    // Show the post creation popup if under the post limit
    showDialog(
      context: context,
      builder: (context) {
        return _buildPostCreationDialog(context);
      },
    );
  }

  // Function to build the post creation dialog
  Widget _buildPostCreationDialog(BuildContext context) {
    TextEditingController captionController = TextEditingController();
    File? selectedImage; // Ensure it's nullable

    return AlertDialog(
      backgroundColor: const Color(0xFF5E92A8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text(
        "Create a New Post",
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      selectedImage = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.cover)
                      : const Center(
                          child: Text(
                            "Tap to Upload Image",
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: captionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Write a caption...",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(fontSize: 16.0, color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            if (selectedImage == null || captionController.text.trim().isEmpty) {
              _showIncompletePostWarning(context);
            } else {
              _uploadPost(context, selectedImage, captionController.text);
              Navigator.pop(context);
            }
          },
          child: const Text("Post", style: TextStyle(fontSize: 16.0, color: Color(0xFFEDCF9E))),
        ),
      ],
    );
  }

  void _showIncompletePostWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF5E92A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(
            "Incomplete Post",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Chewy", fontSize: 22.0, color: Colors.white),
          ),
          content: const Text(
            "Your post is missing an image or caption. Do you want to continue editing or cancel posting?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "VarelaRound", fontSize: 16.0, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert, let user continue editing
              },
              child: const Text(
                "Continue Editing",
                style: TextStyle(fontSize: 16.0, color: Color(0xFFEDCF9E)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the warning
                Navigator.pop(context); // Close the post creation dialog
              },
              child: const Text(
                "Cancel Post",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  void _uploadPost(BuildContext context, File? selectedImage, String caption) {
    if (selectedImage == null || caption.isEmpty) {
      return; // Ensure both image and caption are provided
    }

    setState(() {
      _postCounter++; // Increment ID for the new post
      communityPosts.add({
        "postID": _postCounter,
        "username": "User", // Replace with actual username
        "image": selectedImage.path, // Store the file path
        "caption": caption,
        "timestamp": "Just now", // Set a default timestamp
        "likes": 0,
        "comments": 0,
      });
    });

    Navigator.pop(context); // Close the pop-up after posting
  }

  void _openPostDetails(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(post["username"][0], style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post["username"],
                        style: const TextStyle(
                          fontFamily: "Chewy",
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        post["timestamp"],
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
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  post["image"],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post["caption"],
                style: const TextStyle(
                  fontFamily: "VarelaRound",
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            post["likes"] += 1;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "${post["likes"]} Likes",
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
                        onPressed: () {
                          Navigator.pop(context);
                          _openCommentSection(context, post["postID"]);
                        },
                      ),
                      Text(
                        "${post["comments"]} Comments",
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
            ],
          ),
        );
      },
    );
  }

  void _openCommentSection(BuildContext context, int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return _buildCommentSection(postId);
      },
    );
  }

  Widget _buildCommentSection(int postId) {
    return CommentSection(postId: postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background/page_hello_my_community_01.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        fillColor: const Color(0xFF5E92A8),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        shape: const CircleBorder(),
                        child: Image.asset(
                          'assets/buttons/back_arrow.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          "Hello, My Community!",
                          style: TextStyle(
                            fontFamily: "Chewy",
                            fontSize: 26.0,
                            color: Color(0xFF336B89),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: MasonryGridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0), // Adds spacing around the grid
                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: communityPosts.length,
                    itemBuilder: (context, index) {
                      final post = communityPosts[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0), // Add spacing between photos
                        child: GestureDetector(
                          onTap: () => _openPostDetails(context, post),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.asset(
                              post["image"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _createNewPost(context),
                  backgroundColor: const Color(0xFF336B89),
                  child: const Icon(Icons.add, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final int postId; // Identify which post this belongs to

  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> comments = []; // Temporary storage for comments

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -- START of Header Row (Back Button + Title) --
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context); // Go back to previous screen
                },
              ),

              // Title
              const Text(
                "Comments",
                style: TextStyle(
                  fontFamily: "Chewy",
                  fontSize: 22.0,
                  color: Colors.black,
                ),
              ),

              // Spacer to align title in the center
              const SizedBox(width: 40),
            ],
          ),
          // -- END of Header Row --

          const SizedBox(height: 10),

          // Comment List
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    comments[index],
                    style: const TextStyle(fontFamily: "VarelaRound", fontSize: 16.0),
                  ),
                );
              },
            ),
          ),

          // Comment Input Field
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Write a comment...",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _addComment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
