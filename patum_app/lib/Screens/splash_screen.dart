import 'dart:async';
import 'login.dart';
import 'package:flutter/material.dart';

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
          child: Text(
            'Patum',
            style: TextStyle(
              fontSize: 50.0,
              fontFamily: 'Sacramento',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
