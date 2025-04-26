import 'package:flutter/material.dart';

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
