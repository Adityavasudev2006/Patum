import 'package:flutter/material.dart';
import 'package:Patum/Screens/profile.dart';
import 'package:Patum/Screens/records.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:Patum/Screens/home.dart';

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
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
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
