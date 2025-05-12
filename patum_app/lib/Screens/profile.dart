import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:Patum/Screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  String? _downloadUrl;

  static bool _isFirstLoad = true;
  bool isEditing = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emergencyController;
  late TextEditingController emailController;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    XFile? pickedFile;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      try {
        pickedFile = await picker.pickImage(
          source: source,
        );
      } catch (e) {
        print("Error picking image: $e");
        // Check if the widget is still mounted before showing a SnackBar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error picking image: Could not get access.")),
          );
        }
        return;
      }
    } else {
      print("Image source selection cancelled.");
      return;
    }

    if (pickedFile != null) {
      context.loaderOverlay.show();
      setState(() {
        _imageFile = File(pickedFile!.path);
      });

      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    final email = HomeScreen.current_email;
    if (_imageFile == null || email == null) {
      print(
          "Image file or email is null. Email: $email, ImageFile: $_imageFile");
      return;
    }

    final url = Uri.parse("https://upload.imagekit.io/api/v1/files/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields["fileName"] = "$email.jpg"
      ..fields["publicKey"] = "public_bEcfe0aw3NTB9ANQEk8Zd4S2qz8="
      ..fields["folder"] = "/profile_pics"
      ..fields["useUniqueFileName"] = "true"
      // If I upload another file with same name that should overwrite the existing one.
      ..fields["overwriteFile"] = "true"
      ..files.add(await http.MultipartFile.fromPath("file", _imageFile!.path));

    request.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('private_sgJxaTwgFn1XaNQdq4YEBIlEpQ0=:'))}';

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResp = json.decode(respStr);
      final newImageUrl = jsonResp["url"]; // Get the URL

      setState(() {
        _downloadUrl = newImageUrl;
      });
      print(
          "Attempting to update Firestore for user: $email with URL: $newImageUrl");

      // Update Firestore with ImageKit URL
      final userDetails = await _firestore.collection('user_data').get();
      bool updated = false;
      for (var details in userDetails.docs) {
        if (details['email'] == email) {
          await _firestore.collection('user_data').doc(details.id).update({
            'profile_pic': newImageUrl,
          });
          print("Firestore updated successfully for $email.");
          updated = true;
          break;
        }
      }
      context.loaderOverlay.hide();
      if (!updated) {
        print("Failed to find user $email in Firestore to update profile_pic.");
      }
    } else {
      print("ImageKit Upload failed: $respStr");
      context.loaderOverlay.hide();
    }
  }

  void _fetchProfilePic() async {
    final userDetails = await _firestore.collection('user_data').get();
    for (var details in userDetails.docs) {
      if (details['email'] == HomeScreen.current_email) {
        setState(() {
          _downloadUrl = details['profile_pic'];
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emergencyController = TextEditingController();
    emailController = TextEditingController();

    _fetchProfilePic();

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
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_downloadUrl != null
                                ? NetworkImage(_downloadUrl!)
                                : AssetImage('assets/profile_logo.png'))
                            as ImageProvider,
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
                        onPressed: _pickImage,
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
