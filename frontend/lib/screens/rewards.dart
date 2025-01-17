import 'package:flutter/material.dart';
import 'design.dart'; // Import the file containing `createMaterialColor`.
import 'homepage.dart'; // Import the HomePage

class StickerCollectionPage extends StatefulWidget {
  const StickerCollectionPage({super.key});

  @override
  _StickerCollectionPageState createState() => _StickerCollectionPageState();
}

class _StickerCollectionPageState extends State<StickerCollectionPage> {
  int currentPage = 1;

  // Example data for each page
  final List<List<Color>> pages = [
    List.generate(
      12,
      (index) => createMaterialColor(const Color(0xFF80A6A4)),
    ),
    List.generate(
      12,
      (index) => createMaterialColor(const Color(0xFF8C92AC)),
    ),
    List.generate(
      12,
      (index) => createMaterialColor(const Color(0xFFF1BFA1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF4CAF50)), // Create a custom swatch
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B98A9),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button with custom image that navigates to HomePage
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      child: canvaImage('back_arrow.png', width: 50, height: 50),
                    ),
                    // Cart icon with custom image
                    canvaImage('cart_icon.png', width: 70, height: 70),
                  ],
                ),
              ),
              const Text(
                'COOKAstix Collection',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'Chewy',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: pages[currentPage - 1].length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: pages[currentPage - 1][index],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Page',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(width: 20),
                  for (int i = 1; i <= pages.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPage = i;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage == i
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Chewy',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
