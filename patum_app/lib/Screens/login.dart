import 'package:Patum/Screens/signup.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:Patum/Components/modals.dart';

// Main Login Screen
class HomeScreen extends StatelessWidget {
  static String id = "home_screen";

  static String? current_first_name;
  static String? current_last_name;
  static String? current_phone_no;
  static String? current_email;
  static String? current_ephone_no;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.teal,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal[100],
        title: Text(
          'Patum',
          style: TextStyle(
            // fontSize: 40.0, // Original
            fontSize: 35.0,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sacramento',
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            // radius: 60.0, // Original reduced size
                            radius: 70.0,
                            backgroundImage:
                                AssetImage('assets/profile_logo.png'),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Center(
                          child: SizedBox(
                            width: 150.0,
                            child: Divider(
                              color: Colors.teal[100],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        LoginForm(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isObscured = true;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final modal = Modal();

  void _handleLogin() async {
    // Form is valid
    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show();
      // Form is valid, proceed with login logic
      try {
        if (_emailController.text != null && _passwordController.text != null) {
          final user = await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          //if that user exists in server it wont be null.
          if (user != null) {
            takeProfileDetails();
            context.loaderOverlay.hide();
            Navigator.pushNamed(context, MainPage.id);
          } else {
            context.loaderOverlay.hide();
            await modal.showAccountNotFoundDialog(context);
          }
        }
      } catch (e) {
        context.loaderOverlay.hide();
        await modal.showAccountNotFoundDialog(context);
      }
    } else {}
  }

  void takeProfileDetails() async {
    final userdetails = await _firestore.collection('user_data').get();
    for (var details in userdetails.docs) {
      if (details['email'] == _emailController.text) {
        HomeScreen.current_email = _emailController.text;
        HomeScreen.current_first_name = details['first_name'];
        HomeScreen.current_last_name = details['last_name'];
        HomeScreen.current_phone_no = details['phone_no'];
        HomeScreen.current_ephone_no = details['emergency_no'];
      }
    }
  }

  void _handleSignup() {
    Navigator.pushNamed(context, SignUp.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                hintText: 'Enter your email-id',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey[600]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.grey[900]!, width: 2.0)),
                filled: true,
                fillColor: Colors.teal[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 15.0),
            TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _isObscured,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                hintText: 'Enter your Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey[600]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.grey[900]!, width: 2.0)),
                filled: true,
                fillColor: Colors.teal[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  // Example: Minimum length
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0), // Increased spacing
            MaterialButton(
              minWidth: double.infinity,
              height: 45.0,
              onPressed: _handleLogin,
              child: Text('Login', style: TextStyle(fontSize: 16)),
              color: Colors.teal[300],
              // Slightly darker teal for button
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: _handleSignup,
              child: Text(
                'Do not have an account? Sign Up',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
