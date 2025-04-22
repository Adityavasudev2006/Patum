import 'package:flutter/material.dart';
import '../Screens/records.dart';
import '../Screens/profile.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.homeIconColor,
    required this.recordsIconColor,
    required this.profileIconColor,
    required this.onPressed1,
    required this.onPressed2,
    required this.onPressed3,
  });

  final Color homeIconColor;
  final Color recordsIconColor;
  final Color profileIconColor;
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;
  final VoidCallback onPressed3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 17.0, 0.0, 23.0),
      color: Colors.teal,
      margin: EdgeInsets.only(top: 10.0),
      width: double.infinity,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                onPressed1();
              },
              child: Icon(
                Icons.home,
                size: 35.0,
                color: homeIconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressed2();
              },
              child: Icon(
                Icons.import_contacts_sharp,
                size: 28.0,
                color: recordsIconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                onPressed3();
              },
              child: Icon(
                Icons.person,
                size: 30.0,
                color: profileIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class clickableOptions extends StatelessWidget {
  const clickableOptions({
    super.key,
    required this.optionText,
    required this.logoPlace,
    required this.onPressed,
  });

  final String optionText;
  final String logoPlace;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38.0),
        child: Container(
          width: 160,
          color: Colors.white,
          margin: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                optionText,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 5.0,
              ),
              Image.asset(
                logoPlace,
                width: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
