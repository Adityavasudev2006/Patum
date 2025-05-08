import 'dart:async';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class splash_screen extends StatefulWidget {
  static String id = "splash_screen";

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.teal,
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 50.0,
              fontFamily: 'Sacramento',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Patum',
                  speed: Duration(milliseconds: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
