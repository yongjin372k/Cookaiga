import 'package:flutter/material.dart';

Route fadeTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration:
        const Duration(milliseconds: 500), // Adjust fade duration
  );
}
