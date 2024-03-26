import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lcos/providers/user_provider.dart';
import 'package:lcos/resources/firestore_methods.dart';
import 'package:lcos/responsive/mobile_screen_layout.dart';
import 'package:lcos/screens/snap_or_record.dart';
import 'package:lcos/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  final Uint8List? file;
  final String? videoPath;

  const AddPostScreen({Key? key, this.file, this.videoPath}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  Uint8List? _currentFile;
  String? _videoPath;
  String? selectedGroupId;
  late Future<List<String>> userGroupsFuture;
  late Future<Map<String, String>> groupNamesFuture;

  @override
  void initState() {
    super.initState();
    _currentFile = widget.file;
    _videoPath = widget.videoPath;
    userGroupsFuture = fetchUserGroups();
    groupNamesFuture = fetchGroupNames();
  }

  Future<List<String>> fetchUserGroups() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return await userProvider.getUserGroups(userProvider.getUser.uid);
  }

  Future<Map<String, String>> fetchGroupNames() async {
    Map<String, String> groupNames = {};
    List<String> userGroups = await userGroupsFuture;

    for (String groupUid in userGroups) {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupUid)
          .get();
      if (groupSnapshot.exists) {
        groupNames[groupUid] = groupSnapshot['groupName'] ?? "Unknown Group";
      }
    }

    return groupNames;
  }

  Future<void> postMedia(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    try {
      String res = "";

      if (_currentFile != null && selectedGroupId != null) {
        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);

        // Check if it's an image or video and upload accordingly
        if (_currentFile!.lengthInBytes <= 5000000) {
          res = await FireStoreMethods().uploadPost(
            _descriptionController.text,
            _currentFile!,
            uid,
            username,
            profImage,
            false, // It's an image
            groupId: selectedGroupId,
          );
        } else {
          // Handle video upload if needed
          res = await FireStoreMethods().uploadPostWithVideo(
            _descriptionController.text,
            _currentFile!,
            uid,
            username,
            profImage,
            _videoPath!,
            groupId: selectedGroupId,
          );
        }

        if (res == "success") {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context, 'Posted!');
          clearMedia();

          // Navigate to MobileScreenLayout on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MobileScreenLayout()),
          );
        } else {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, err.toString());
    }
  }

  void clearMedia() {
    setState(() {
      _currentFile = null;
      _videoPath = null;
      _descriptionController.clear();
      selectedGroupId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: widget.file == null
          ? SnapOrRecord()
          : Scaffold(
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: _currentFile != null
                          ? Image.memory(_currentFile!, fit: BoxFit.cover)
                          : Container(), // Adjust based on your design
                    ),
                  ),
                  const Divider(),
                  // Display User Groups
                  FutureBuilder<Map<String, String>>(
                    future: groupNamesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        Map<String, String> groupNames = snapshot.data ?? {};
                        if (groupNames.isNotEmpty) {
                          return Column(
                            children: [
                              Text("Select Group:"),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: groupNames.keys.map((groupUid) {
                                    String groupName =
                                        groupNames[groupUid] ?? "Unknown Group";

                                    return Row(
                                      children: [
                                        Radio(
                                          value: groupUid,
                                          groupValue: selectedGroupId,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGroupId =
                                                  value as String?;
                                            });
                                          },
                                        ),
                                        Text(groupName),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text("User is not in any groups");
                        }
                      }
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          userProvider.getUser.photoUrl,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                              hintText: "Write a caption...",
                              border: InputBorder.none),
                          maxLines: 8,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: isLoading
                    ? null
                    : () => postMedia(
                          userProvider.getUser.uid,
                          userProvider.getUser.username,
                          userProvider.getUser.photoUrl,
                        ),
                child: const Icon(Icons.send),
              ),
            ),
    );
  }
}
