import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lcos/resources/storage_methods.dart';
import 'package:lcos/utils/colors.dart';
import 'package:lcos/utils/utils.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;

  const GroupSettingsScreen({Key? key, required this.groupId})
      : super(key: key);

  @override
  _GroupSettingsScreenState createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late CustomGroup group;
  TextEditingController groupNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? _imageFile;
  ImageProvider<Object>? _groupImage;
  bool isPrivate = false;
  List<String> admins = [];
  List<String> members = [];

  @override
  void initState() {
    super.initState();
    fetchGroupData();
    fetchAdmins();
    fetchMembers();
  }

  void fetchGroupData() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        setState(() {
          group = CustomGroup.fromSnap(groupSnapshot);
          groupNameController.text = group.groupName;
          descriptionController.text = group.description;
          isPrivate = group.privacy == 'Private';

          // Set the background image for the CircleAvatar
          _updateGroupImage();
        });
      }
    } catch (e) {
      print('Error fetching group data: $e');
    }
  }

  void _updateGroupImage() {
    if (group.groupImage.isNotEmpty) {
      setState(() {
        _groupImage = NetworkImage(group.groupImage);
      });
    } else {
      setState(() {
        _groupImage = AssetImage("assets/images/default_group_image.png");
      });
    }
  }

  void updateGroupData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'groupName': groupNameController.text,
        'description': descriptionController.text,
        'privacy': isPrivate ? 'Private' : 'Public',
      });

      setState(() {
        group.groupName = groupNameController.text;
        group.description = descriptionController.text;
        group.privacy = isPrivate ? 'Private' : 'Public';
      });

      // Show a SnackBar with the message "Changes Saved"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes Saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating group data: $e');
    }
  }

  void fetchMembers() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        List<String> membersList =
            List<String>.from(groupSnapshot['members'] ?? []);

        setState(() {
          members = membersList;
        });
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  void deleteGroupAndPosts(BuildContext context) async {
    try {
      // Delete the group document
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      // Delete all posts with the same groupId
      await FirebaseFirestore.instance
          .collection('posts')
          .where('groupId', isEqualTo: widget.groupId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Show a SnackBar with the message "Group deleted successfully"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the previous screen or perform any other navigation logic
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting group and posts: $e');
    }
  }

  Widget buildMembersListTile(String memberUid) {
    return ListTile(
      title: FutureBuilder(
        future: getUsernameFromUid(memberUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String username = snapshot.data.toString();
            return Text(username);
          }
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              updateMembersList(context, memberUid);
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_upward),
            onPressed: () {
              promoteToAdmin(context, memberUid);
            },
          ),
        ],
      ),
    );
  }

  void promoteToAdmin(BuildContext context, String uid) async {
    try {
      // Remove uid from members list
      members.remove(uid);

      // Update members field in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'members': members,
      });

      // Add uid to admins list
      admins.add(uid);

      // Update admins field in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'admins': admins,
      });

      // Show a SnackBar with the message "Member promoted to Admin"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member promoted to Admin'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error promoting member to admin: $e');
    }
  }

  void updateMembersList(BuildContext context, String uid) async {
    try {
      // Remove uid from members list
      members.remove(uid);

      // Update members field in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'members': members,
      });

      // Show a SnackBar with the message "Member removed"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member removed'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating members list: $e');
    }
  }

  void fetchAdmins() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        List<String> adminsList =
            List<String>.from(groupSnapshot['admins'] ?? []);

        setState(() {
          admins = adminsList;
        });
      }
    } catch (e) {
      print('Error fetching admins: $e');
    }
  }

  void updateAdminsList(BuildContext context, String uid) async {
    try {
      // Remove uid from admins list
      admins.remove(uid);

      // Update admins field in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'admins': admins,
      });

      // Add uid to members list
      members.add(uid);

      // Update members field in Firestore
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'members': members,
      });

      // Show a SnackBar with the message "Admin removed"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin removed'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating admins list: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);

      if (pickedImage != null) {
        File? croppedFile = await _cropImage(File(pickedImage.path));

        if (croppedFile != null) {
          String imageUrl = await _uploadImageToStorage(croppedFile);
          await _updateGroupImageInFirestore(imageUrl);

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
      String childName = 'groupImages';

      String imageUrl = await StorageMethods()
          .uploadImageToStorage(childName, imageData, false);

      return imageUrl;
    } catch (e) {
      throw Exception('Error uploading image to storage: $e');
    }
  }

  Future<void> _updateGroupImageInFirestore(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'groupImage': imageUrl,
      });

      setState(() {
        group.groupImage = imageUrl;
      });
    } catch (e) {
      print('Error updating group image in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Group Settings'),
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
                          : _groupImage,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 25),
                child: Text(
                  'Group Info',
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
                      buildTextField("Group Name", groupNameController),
                      buildTextField("Description", descriptionController),
                      buildPrivacySwitch(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 25),
                child: Text(
                  'List of Admins',
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
                      // List all admins and remove buttons
                      for (String adminUid in admins) ...[
                        buildAdminListTile(adminUid),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 25),
                child: Text(
                  'List of Members',
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
                      // List all members and remove buttons
                      for (String memberUid in members) ...[
                        buildMembersListTile(memberUid),
                      ],
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
                        updateGroupData(context);
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.red, // Change color as desired
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Call the method to delete the group and related posts
                        deleteGroupAndPosts(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Delete Group',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

  Widget buildPrivacySwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Privacy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Row(
          children: [
            Text('Public'),
            Switch(
              value: isPrivate,
              onChanged: (value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
            Text('Private'),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildAdminListTile(String adminUid) {
    bool isCurrentUserAdmin = admins.contains(adminUid);
    bool isCurrentUser = adminUid == FirebaseAuth.instance.currentUser?.uid;

    return ListTile(
      title: FutureBuilder(
        future: getUsernameFromUid(adminUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String username = snapshot.data.toString();
            return Text(
              username,
              style: TextStyle(
                color: isCurrentUserAdmin ? Colors.green : Colors.black,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }
        },
      ),
      trailing: isCurrentUserAdmin && !isCurrentUser
          ? IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                updateAdminsList(context, adminUid);
              },
            )
          : null,
    );
  }

  Future<String> getUsernameFromUid(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        return userSnapshot['username'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }
}

class CustomGroup {
  late String groupImage;
  late String groupName;
  late String description;
  late String privacy;

  CustomGroup({
    required this.groupImage,
    required this.groupName,
    required this.description,
    required this.privacy,
  });

  CustomGroup.fromMap(Map<String, dynamic>? map)
      : groupImage = map?['groupImage'] ?? '',
        groupName = map?['groupName'] ?? '',
        description = map?['description'] ?? '',
        privacy = map?['privacy'] ?? '';

  static CustomGroup fromSnap(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return CustomGroup(
      groupImage: data['groupImage'] ?? '',
      groupName: data['groupName'] ?? '',
      description: data['description'] ?? '',
      privacy: data['privacy'] ?? '',
    );
  }
}
