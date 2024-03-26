import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lcos/screens/group_feed_screen.dart';
import 'package:lcos/utils/utils.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _privacyValue;
  String? _categoryValue;
  bool agreeToTerms = false;
  bool isButtonEnabled = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController adminsController = TextEditingController();
  File? _groupImageFile;
  bool _isLoading = false;

  Future<void> _pickGroupImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        File? croppedFile = await _cropGroupImage(File(pickedImage.path));

        if (croppedFile != null) {
          String groupImageUrl = await _uploadGroupImageToStorage(croppedFile);
          await _updatePhotoUrlInFirestore(groupImageUrl);

          setState(() {
            _groupImageFile = croppedFile;
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

  Future<File?> _cropGroupImage(File image) async {
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

  Future<String> _uploadGroupImageToStorage(File imageFile) async {
    try {
      Uint8List imageData = await imageFile.readAsBytes();
      String childName = 'groupPics';

      String groupImageUrl = await StorageMethods()
          .uploadImageToStorage(childName, imageData, false);

      return groupImageUrl;
    } catch (e) {
      throw Exception('Error uploading image to storage: $e');
    }
  }

  Future<void> _updatePhotoUrlInFirestore(String groupImageUrl) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Example: await FirebaseFirestore.instance.collection('groups').doc(uid).update({
    //   'groupPhotoUrl': groupImageUrl,
    // });

    setState(() {
      // Update your local state if needed
    });
  }

  Future<void> _createGroup() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true; // Set loading state to true
        });

        // Validating the form fields
        String uid = FirebaseAuth.instance.currentUser!.uid;
        String groupName = _groupNameController.text;
        String privacy = _privacyValue ?? 'Public';
        String description = _descriptionController.text;
        int maxAdmin = int.tryParse(adminsController.text) ?? 0;
        String category = _categoryValue ?? 'Community';
        DateTime timeCreated = DateTime.now();

        // Upload group image to storage
        String groupImageUrl = '';
        if (_groupImageFile != null) {
          groupImageUrl = await _uploadGroupImageToStorage(_groupImageFile!);
        }

        // Create group data
        Map<String, dynamic> groupData = {
          'id': uid, // Add ID field
          'groupImage': groupImageUrl,
          'groupName': groupName,
          'privacy': privacy,
          'description': description,
          'maxAdmin': maxAdmin,
          'category': category,
          'timeCreated': timeCreated,
          'admins': [uid], // The creator is the initial admin
          'members': [], // Initialize an empty members list
        };

        // Add group data to Firestore
        DocumentReference groupRef = await FirebaseFirestore.instance
            .collection('groups')
            .add(groupData);

        // Extract the ID after adding to Firestore
        String groupId = groupRef.id;

        // Update the 'id' field in Firestore
        await groupRef.update({'id': groupId});

        // Calculate the total number of users and update 'users' field
        int totalUsers = (groupData['admins'] as List).length;
        await groupRef.update({'users': totalUsers});

        // Navigate to the GroupFeedScreen page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupFeedScreen(
              groupId: groupId,
              searchQueryController: TextEditingController(),
            ),
          ),
        );
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isLoading =
            false; // Set loading state to false regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Group'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(50.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _pickGroupImage();
                        },
                        child: Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: _groupImageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    _groupImageFile!,
                                    width: 120.0,
                                    height: 120.0,
                                    fit:
                                        BoxFit.cover, // Adjust the fit property
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 50.0,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _groupNameController,
                      decoration: InputDecoration(labelText: 'Group Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<String>(
                      value: _privacyValue,
                      items: ['Public', 'Private'].map((String privacy) {
                        return DropdownMenuItem<String>(
                          value: privacy,
                          child: Text(privacy),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _privacyValue = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Privacy'),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration:
                          InputDecoration(labelText: 'Group Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a group description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: adminsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Admins (max: 10)',
                        errorText: adminsController.text.isNotEmpty &&
                                int.tryParse(adminsController.text) == null
                            ? 'Please enter a valid number'
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of admins';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<String>(
                      value: 'Community',
                      items:
                          ['Community', 'Organization'].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Handle category selection
                      },
                      decoration: InputDecoration(labelText: 'This Group For'),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value!;
                              isButtonEnabled = value;
                            });
                          },
                        ),
                        Text(
                          'I admit that this group was\nnot established with the intention\nof evil and obscene elements',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    if (adminsController.text.isNotEmpty &&
                        (int.tryParse(adminsController.text) ?? 0) > 10)
                      Text(
                        'Note: Number of admins should not exceed 10',
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: isButtonEnabled ? _createGroup : null,
                      child: Text('Create Group'),
                      style: ElevatedButton.styleFrom(
                        primary: isButtonEnabled ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
