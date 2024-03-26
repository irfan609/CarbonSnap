import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lcos/constants.dart';

class GroupInvitationScreen {
  static Future<void> showInviteDialog(
      BuildContext context, String groupId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user's following and followers arrays
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    List<String> following =
        List<String>.from(userDoc.data()?['following'] ?? []);
    List<String> followers =
        List<String>.from(userDoc.data()?['followers'] ?? []);

    if (following.isEmpty && followers.isEmpty) {
      // No accounts in 'following' and 'followers', show the default message
      _showDefaultInviteDialog(context);
      return;
    }

    // Merge following and followers
    List<String> allUsers = [...following, ...followers];

    // Fetch usernames, photoUrls for merged list
    List<Map<String, String>> allUserDetailList =
        await _fetchUserDetails(allUsers);

    // Map to store checkbox states
    Map<String, bool> checkboxStates = {};
    for (String uid in allUsers) {
      checkboxStates[uid] = false;
    }

    // Controller for the search bar
    TextEditingController searchController = TextEditingController();

    // List for the current displayed user details
    List<Map<String, String>> userDetailList = List.from(allUserDetailList);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Search bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by username',
                    ),
                    onChanged: (query) {
                      // Filter userDetailList based on the search query
                      if (query.isNotEmpty) {
                        userDetailList = allUserDetailList
                            .where((user) =>
                                user['username']
                                    ?.toLowerCase()
                                    .contains(query.toLowerCase()) ??
                                false)
                            .toList();
                      } else {
                        // If query is empty, show all users
                        userDetailList = List.from(allUserDetailList);
                      }

                      // Update the UI with the filtered list
                      setState(() {});
                    },
                  ),

                  SizedBox(height: 20.0),

                  _buildInviteList(context, userDetailList, checkboxStates,
                      (String userId, bool value) {
                    setState(() {
                      checkboxStates[userId] = value;
                    });
                  }),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle the invitation logic
                      List<String> selectedUsers = checkboxStates.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      // Send notification and update groupId field
                      await _sendInvitationNotification(groupId, selectedUsers);

                      Navigator.pop(
                          context); // Close the bottom sheet after inviting
                    },
                    style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Send Invitation',
                        style: TextStyle(fontSize: 17, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<List<Map<String, String>>> _fetchUserDetails(
      List<String> uids) async {
    List<Map<String, String>> userDetailsList = [];
    for (String uid in uids) {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String username = userDoc.data()?['username'] ?? 'Unknown User';
      String photoUrl = userDoc.data()?['photoUrl'] ??
          ''; // Replace with the actual field name
      userDetailsList.add({
        'uid': uid,
        'username': username,
        'photoUrl': photoUrl,
      });
    }
    return userDetailsList;
  }

  static Widget _buildInviteList(
      BuildContext context,
      List<Map<String, String>> accounts,
      Map<String, bool> checkboxStates,
      Function(String, bool) onCheckboxChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200.0, // Adjust the height as needed
          child: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              String uid = accounts[index]['uid'] ?? '';
              String username = accounts[index]['username'] ?? '';
              String photoUrl = accounts[index]['photoUrl'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : NetworkImage(
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                        ),
                ),
                title: Text(username),
                trailing: Checkbox(
                  value: checkboxStates[uid] ?? false,
                  onChanged: (bool? value) {
                    onCheckboxChanged(uid, value ?? false);
                  },
                ),
                // Add more UI components as needed for each account
              );
            },
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  static void _showDefaultInviteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Invite Friends',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Invite your friends to join this group!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _sendInvitationNotification(
      String groupId, List<String> selectedUsers) async {
    // Send notification logic here

    // Update groupId field using the provided groupId
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc('group_invitations')
        .update({
      groupId: FieldValue.arrayUnion(selectedUsers),
    });
  }
}
