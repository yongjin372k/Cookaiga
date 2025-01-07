import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  // This is for creating primary swatch. Use the argument shown in main.dart
  List<double> strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

const TextStyle textHeader = TextStyle(
  // This is used in labelling headers
  fontSize: 22,
  color: Color.fromRGBO(255, 255, 255, 1),
  height: 1,
  fontFamily: 'Chewy', // Reference the family name in pubspec.yaml
);

const TextStyle textBody = TextStyle(
  // For body texts
  fontSize: 16,
  color: Color.fromRGBO(255, 255, 255, 1),
  height: 1,
  fontFamily: 'Chewy', // Reference the family name in pubspec.yaml
);

Image canvaImage(String assetName, {double width = 200, double height = 200}) {
  // For inserting images
  return Image.asset(
    'assets/logo/$assetName',
    width: width,
    height: height,
  );
}
