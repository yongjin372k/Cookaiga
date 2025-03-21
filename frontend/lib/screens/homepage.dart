import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/mykitchen_01.dart';
import 'package:frontend/screens/community_screen.dart';
import 'package:frontend/screens/rewards.dart';
import 'package:frontend/screens/jwtDecodeService.dart';
import 'package:frontend/screens/authpage.dart';
import 'design.dart';
import 'letscook_01.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF000000)),
      body: const Center(
        child: HomePageContent(),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Future<int>? _userPoints;
  final JwtService _jwtService = JwtService();

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  void _fetchUserPoints() {
    setState(() {
      _userPoints = _getUserPoints();
    });
  }

  // Fetch user points from backend
  Future<int> _getUserPoints() async {
    int? userID = await _jwtService.getUserID();
    if (userID == null) return 0;

    final String apiUrl = "$URL/api/users/$userID";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['points'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Logout function
  Future<void> _logout() async {
    await _jwtService.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: createMaterialColor(const Color(0xFF80A6A4)),
      body: Stack(
        children: [
          // Top Bar (Menu Button & Points)
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                canvaImage('menu_button.png', width: 50, height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StickerCollectionPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: createMaterialColor(const Color(0xFF336B89)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        canvaImage('reward_coin.png', width: 20, height: 20),
                        const SizedBox(width: 8),
                        FutureBuilder<int>(
                          future: _userPoints,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('...', style: textBody);
                            } else if (snapshot.hasError) {
                              return const Text('Error', style: textBody);
                            } else {
                              return Text('${snapshot.data}', style: textBody);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Let's cook up \nsomething special!",
                    style: textHeader,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LetsCook01Content()));
                    },
                    child: canvaImage('lets_cook.png', width: 140, height: 140),
                  ),
                  const SizedBox(height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyKitchen01Content()));
                    },
                    child: canvaImage('view_my_kitchen.png', width: 140, height: 140),
                  ),
                  const SizedBox(height: 1),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityPage()));
                    },
                    child: canvaImage('hello_my_community.png', width: 140, height: 140),
                  ),
                  const SizedBox(height: 1),
                ],
              ),
            ),
          ),

          // Logout Button (Bottom Left)
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
