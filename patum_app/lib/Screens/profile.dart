import 'package:Patum/Screens/home.dart';
import 'package:Patum/Screens/records.dart';
import 'package:flutter/material.dart';
import 'package:Patum/Components/bottom_bar.dart';
import 'package:Patum/Screens/login.dart';

String? first_name = HomeScreen.current_first_name;
String? last_name = HomeScreen.current_last_name;
String? email = HomeScreen.current_email;
String? phone_no = HomeScreen.current_phone_no;
String? ephone_no = HomeScreen.current_ephone_no;

class ProfileScreen extends StatefulWidget {
  static String id = "profile_screen";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  final firstNameController = TextEditingController(text: first_name);
  final lastNameController = TextEditingController(text: last_name);
  final phoneController = TextEditingController(text: phone_no);
  final emergencyController = TextEditingController(text: ephone_no);
  final emailController = TextEditingController(text: email);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.teal),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              SizedBox(
                height: 125,
                width: 125,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_logo.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt_outlined, size: 18),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildEditableTile(
                  icon: Icons.person_2_outlined,
                  controller: firstNameController),
              _buildEditableTile(
                  icon: Icons.person_2_outlined,
                  controller: lastNameController),
              _buildEditableTile(
                  icon: Icons.phone, controller: phoneController),
              _buildEditableTile(
                  icon: Icons.phone_in_talk, controller: emergencyController),
              _buildEditableTile(
                  icon: Icons.email_outlined, controller: emailController),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 150),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(0.5),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.check : Icons.edit,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        isEditing ? 'Save' : 'Edit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 95, // or any height you want for the navbar
          child: BottomBar(
            homeIconColor: Colors.white,
            recordsIconColor: Colors.white,
            profileIconColor: Colors.red,
            onPressed1: () {
              Navigator.pushNamed(context, MainPage.id);
            },
            onPressed2: () {
              Navigator.pushNamed(context, Records.id);
            },
            onPressed3: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTile({
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.teal[50],
            padding: EdgeInsets.all(25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {},
          child: Row(
            children: [
              Icon(icon, color: Colors.teal, size: 25),
              SizedBox(width: 20),
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.grey[800],
                        ),
                      )
                    : Text(
                        controller.text,
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.grey[700],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
