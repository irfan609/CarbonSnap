import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lcos/resources/storage_methods.dart';
import 'package:lcos/screens/delete_acc.dart';
import 'package:lcos/screens/security_question.dart';
import 'package:lcos/screens/resetPass.dart';
import 'package:lcos/utils/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; 
import 'package:lcos/utils/utils.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late User user;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? _imageFile;
  ImageProvider<Object>? _avatarImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      setState(() {
        user = User.fromSnap(userSnapshot);
        usernameController.text = user.username;
        bioController.text = user.bio;
        emailController.text = user.email;

        // Set the background image for the CircleAvatar
        _updateAvatarImage();
      });
    }
  }

  void _updateAvatarImage() {
    if (user.photoUrl.isNotEmpty) {
      setState(() {
        _avatarImage = NetworkImage(user.photoUrl);
      });
    } else {
      setState(() {
        _avatarImage = AssetImage("assets/images/logo.png");
      });
    }
  }

  void updateUserData(BuildContext context) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': usernameController.text,
      'bio': bioController.text,
      'email': emailController.text,
    });

    setState(() {
      user.username = usernameController.text;
      user.bio = bioController.text;
      user.email = emailController.text;
    });

    // Show a SnackBar with the message "Changes Saved"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes Saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);

      if (pickedImage != null) {
        File? croppedFile = await _cropImage(File(pickedImage.path));

        if (croppedFile != null) {
          String imageUrl = await _uploadImageToStorage(croppedFile);
          await _updatePhotoUrlInFirestore(imageUrl);

          setState(() {
            _imageFile = croppedFile;
          });
        } else {
          showSnackBar(context, 'Image cropping failed.');
        }
      } else {
        showSnackBar(context, 'Image selection failed.');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<File?> _cropImage(File image) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [CropAspectRatioPreset.original],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      Uint8List imageData = await imageFile.readAsBytes();
      String childName = 'profilePics';

      String imageUrl = await StorageMethods()
          .uploadImageToStorage(childName, imageData, false);

      return imageUrl;
    } catch (e) {
      throw Exception('Error uploading image to storage: $e');
    }
  }

  Future<void> _updatePhotoUrlInFirestore(String imageUrl) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'photoUrl': imageUrl,
    });

    setState(() {
      user.photoUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                    },
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: kPrimaryColor,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : _avatarImage,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 25),
                child: Text(
                  'General',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 15,
                  bottom: 40,
                ),
                child: Container(
                  width: 370,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(4, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 25,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField("Username", usernameController),
                      buildTextField("Bio", bioController),
                      buildTextField("Email", emailController),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        updateUserData(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 25),
                child: Text(
                  'Privacy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 15,
                  bottom: 40,
                ),
                child: Container(
                  width: 370,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(4, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 25,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildPrivacyButton("Set Security Password"),
                      buildPrivacyButton("Reset Password"),
                      buildPrivacyButton("Delete Account"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPrivacyButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (buttonText == "Set Security Password") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecurityQuestionPage(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  onSecurityQuestionSet: (securityQuestion) {
                    print('Security Question Set: $securityQuestion');
                  },
                ),
              ),
            );
          } else if (buttonText == "Reset Password") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPassPage(),
              ),
            );
          } else if (buttonText == "Delete Account") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeleteAccountPage(),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextField(
          controller: controller,
          maxLines: 1,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class User {
  late String photoUrl;
  late String username;
  late String bio;
  late String email;

  User({
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.email,
  });

  User.fromMap(Map<String, dynamic>? map)
      : photoUrl = map?['photoUrl'] ?? '',
        username = map?['username'] ?? '',
        bio = map?['bio'] ?? '',
        email = map?['email'] ?? '';

  // Corrected method name to fromSnapshot
  static User fromSnap(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return User(
      photoUrl: data['photoUrl'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
