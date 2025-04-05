import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

String policeNumber = '9400421733';
String pNumber = '';
String medicalNumber = '9999999999';
String emergencyNumber = '8888888888';

class CallModule {
  static callNumber() async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(pNumber);
    if (res == true) {
      print("Call Initiated");
    } else if (res == false) {
      print("Call Failed");
    } else {
      print("Call cancelled or error occurred");
    }
  }
}
