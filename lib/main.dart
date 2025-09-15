import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(KafexApp());
}

class KafexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafex',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}