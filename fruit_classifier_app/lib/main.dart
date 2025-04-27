import 'package:flutter/material.dart';
import 'package:fruit_classifier_app/screens/splash_screen.dart';

void main() {
  runApp(FruitClassifierApp());
}

class FruitClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit Classifier',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
          secondary: Colors.orangeAccent,
        ),
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
          displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.green[700]),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
