import 'package:Patum/Screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'Screens/home.dart';
import 'package:Patum/Screens/records.dart';
import 'package:Patum/Screens/chatbot.dart';
import 'Screens/splash_screen.dart';
import 'package:Patum/Screens/login.dart';
import 'package:Patum/Screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await dotenv.load(fileName: ".env");
  runApp(Patum());
}

class Patum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) => Center(
        child: SpinKitSpinningLines(
          color: Colors.blue,
          size: 50.0,
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Patum',
        home: splash_screen(),
        routes: {
          SignUp.id: (context) => SignUp(),
          HomeScreen.id: (context) => HomeScreen(),
          splash_screen.id: (context) => splash_screen(),
          MainPage.id: (context) => MainPage(),
          Records.id: (context) => Records(),
          ProfileScreen.id: (context) => ProfileScreen(),
          ChatBot.id: (context) => ChatBot(),
        },
      ),
    );
  }
}
