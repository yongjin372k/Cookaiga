import 'dart:async';
import 'package:flutter/material.dart';
import 'page_home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomxePage after a 3-second delay
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Center(
            child: Image.asset('assets/buttons/splashscreen_one.png'),
          ),
          
          Positioned(
            bottom: 16.0, // adjust bottom padding as needed
            left: 0,
            right: 0,
            child: Text(
              "Terms and conditions govern your use of COOKAiGA.\nBy using this App, you agree to be bound by these terms.\n\nTeam Helyx, 2025.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'VarelaRound',
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

