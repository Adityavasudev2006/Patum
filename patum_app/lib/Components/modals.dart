import 'package:Patum/Screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class Modal {
  Future<void> showAccountNotFoundDialog(BuildContext context) async {
    final result = await showCupertinoModalPopup(
      context: context,
      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Account Not Found',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        message: Text(
          'No account found with these credentials',
          style: TextStyle(color: CupertinoColors.secondaryLabel),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'retry'),
            child: Text(
              'Try Again',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, 'signup'),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
        ),
      ),
    );

    if (result == 'signup') {
      Navigator.pushNamed(context, SignUp.id);
    }
  }

  Future<void> showAccountExistsDialog(BuildContext context) async {
    final result = await showCupertinoModalPopup(
      context: context,
      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Account Already Registered',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        message: Text(
          'Account has already been created in this Gmail id',
          style: TextStyle(color: CupertinoColors.secondaryLabel),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'retry'),
            child: Text(
              'Try Again',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, 'login'),
            child: Text(
              'Log In',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
        ),
      ),
    );

    if (result == 'login') {
      Navigator.pop(context);
    }
  }
}
