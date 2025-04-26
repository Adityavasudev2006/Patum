import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:Patum/Screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static bool _isFirstLoad = true;
  bool isEditing = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emergencyController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emergencyController = TextEditingController();
    emailController = TextEditingController();

    if (_isFirstLoad) {
      print(
          "ProfileScreen: First load detected, initializing from HomeScreen statics.");
      firstNameController.text = HomeScreen.current_first_name ?? '';
      lastNameController.text = HomeScreen.current_last_name ?? '';
      phoneController.text = HomeScreen.current_phone_no ?? '';
      emergencyController.text = HomeScreen.current_ephone_no ?? '';
      emailController.text = HomeScreen.current_email ?? '';

      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emergencyController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void saveProfile(String firstName, String lastName, String phone,
      String emergencyPhone, String email) async {
    context.loaderOverlay.show();

    final userDetails = await _firestore.collection('user_data').get();

    for (var details in userDetails.docs) {
      if (details['email'] == HomeScreen.current_email) {
        // To update the document in Firestore
        await _firestore.collection('user_data').doc(details.id).update({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_no': phone,
          'emergency_no': emergencyPhone,
        });

        break; // Break the loop after updating the matched user
      }
    }
    final user = await _auth.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(email); // Sends verification email
        print("Verification email sent to $email. Please verify to update.");
      } catch (e) {
        print("Failed to send verification email: $e");
      }
    } else {
      print("No user currently signed in.");
    }

    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.teal),
        ),
        automaticallyImplyLeading: false,
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
                icon: Icons.person_2_outlined, controller: firstNameController),
            _buildEditableTile(
                icon: Icons.person_2_outlined, controller: lastNameController),
            _buildEditableTile(icon: Icons.phone, controller: phoneController),
            _buildEditableTile(
                icon: Icons.phone_in_talk, controller: emergencyController),
            _buildEditableTile(
                icon: Icons.email_outlined, controller: emailController),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        left: 30, right: 15), // Adjusted margins
                    decoration: BoxDecoration(
                      color: Colors.grey, // Grey color for logout
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        context.loaderOverlay.show();
                        context.loaderOverlay.show();
                        await _auth.signOut();

                        _isFirstLoad = true;

                        HomeScreen.current_first_name = null;
                        HomeScreen.current_last_name = null;
                        HomeScreen.current_phone_no = null;
                        HomeScreen.current_ephone_no = null;
                        HomeScreen.current_email = null;

                        firstNameController.clear();
                        lastNameController.clear();
                        phoneController.clear();
                        emergencyController.clear();
                        emailController.clear();

                        Navigator.pushNamedAndRemoveUntil(
                            context, HomeScreen.id, (route) => false);
                        context.loaderOverlay.hide();
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
                            Icons.logout,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
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
                ),
                // Existing Edit/Save Button
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        left: 15, right: 30), // Adjusted margins
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
                          if (isEditing) {
                            // Save updated values
                            saveProfile(
                              firstNameController.text,
                              lastNameController.text,
                              phoneController.text,
                              emergencyController.text,
                              emailController.text,
                            );
                          }
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
                ),
              ],
            ),
            SizedBox(height: 100),
          ],
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
