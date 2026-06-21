import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/fitness_app/food_icon.png', // Add this image or change to another suitable image
              height: 100,
              width: 100,
            ),
            SizedBox(height: 24),
            Text(
              'Analyzing your food...',
              style: FitnessAppTheme.title,
            ),
            SizedBox(height: 16),
            Text(
              'Our AI is cooking up some delicious recipes for you!',
              textAlign: TextAlign.center,
              style: FitnessAppTheme.subtitle,
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(FitnessAppTheme.nearlyDarkBlue),
            ),
          ],
        ),
      ),
    );
  }
}
