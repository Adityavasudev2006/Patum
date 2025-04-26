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
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
          MainNavigationWrapper.id: (context) => MainNavigationWrapper(),
          splash_screen.id: (context) => splash_screen(),
          ChatBot.id: (context) => ChatBot(),
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  static String id = "main_navigation_wrapper";

  static _MainNavigationWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainNavigationWrapperState>();
  }

  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MainPage(),
    Records(),
    ProfileScreen(),
  ];

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  void navigateToProfile() {
    setState(() {
      _currentIndex = 2; // Profile is at index 2
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        body: _pages[_currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context)
              .copyWith(iconTheme: IconThemeData(color: Colors.teal)),
          child: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: _currentIndex,
            height: 70.0,
            items: <Widget>[
              Icon(Icons.home, size: 30),
              Icon(Icons.list_alt, size: 30),
              Icon(Icons.person, size: 30),
            ],
            color: Colors.white,
            buttonBackgroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 600),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            letIndexChange: (index) => true,
          ),
        ),
      ),
    );
  }
}
