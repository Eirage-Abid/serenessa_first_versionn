import 'package:flutter/material.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade-in effect
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
    // Navigate to home screen after 4 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
        /**  Image.asset(
            'assets/images/women_illustration1.png',
            fit: BoxFit.cover,
          ),**/
          // Centered Logo with Fade-in
          Center(
            child: AnimatedOpacity(
              duration: Duration(seconds: 4),
              opacity: _opacity,
              child: Image.asset(
                'assets/images/Serenessa_logo.png',
                width: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
