import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Patum/Screens/chatbot.dart';
import 'Screens/splash_screen.dart';
import 'package:Patum/Screens/login.dart';
import 'package:Patum/Screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Patum/Components/bottom_bar.dart';
import 'package:Patum/Services/background_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await dotenv.load(fileName: ".env");

  BackgroundServices.startTimer();
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
          MainNavigationWrapper.id: (context) => MainNavigationWrapper(),
          splash_screen.id: (context) => splash_screen(),
          ChatBot.id: (context) => ChatBot(),
        },
      ),
    );
  }
}
