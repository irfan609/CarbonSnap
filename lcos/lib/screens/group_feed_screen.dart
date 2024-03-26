import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lcos/models/group.dart';
import 'package:lcos/responsive/mobile_screen_layout.dart';
import 'package:lcos/screens/create_group.dart';
import 'package:lcos/screens/group_invitation_screen.dart';
import 'package:lcos/screens/group_setting.dart';
import 'package:lcos/screens/socmed_drawer.dart';
import 'package:lcos/utils/colors.dart';
import 'package:lcos/widgets/post_card.dart';

class GroupFeedScreen extends StatefulWidget {
  final String groupId;
  final TextEditingController searchQueryController;

  const GroupFeedScreen({
    Key? key,
    required this.groupId,
    required this.searchQueryController,
  }) : super(key: key);

  @override
  _GroupFeedScreenState createState() => _GroupFeedScreenState();
}

class _GroupFeedScreenState extends State<GroupFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;
  late Group group;
  bool isCurrentUserMemberOrAdmin = false;
  bool isCurrentUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
    _updatePostsStream();
    _checkMembershipStatus(); // Check if the current user is a member or admin
    _listenForUsersChanges();
  }

  void _checkMembershipStatus() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> groupDoc = await FirebaseFirestore
          .instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      List<dynamic> members = groupDoc.data()?['members'] ?? [];
      List<dynamic> admins = groupDoc.data()?['admins'] ?? [];

      setState(() {
        isCurrentUserMemberOrAdmin =
            members.contains(uid) || admins.contains(uid);
        isCurrentUserAdmin = admins.contains(uid);
      });
    } catch (e) {
      print('Error checking membership status: $e');
    }
  }

  void _listenForUsersChanges() {
    // Listen for changes in 'admins' and 'members'
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        // Update 'users' field with the total number of users
        int totalUsers = (snapshot.data()?['admins'] as List).length +
            (snapshot.data()?['members'] as List).length;

        FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({'users': totalUsers});
      }
    });
  }

  void _goToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(),
      ),
    );
  }

  void _showInviteDialog() async {
    GroupInvitationScreen.showInviteDialog(context, widget.groupId);
  }

  void _fetchGroupData() async {
    try {
      // Fetch the group data from Firestore using the groupId
      DocumentSnapshot<Map<String, dynamic>> groupDoc = await FirebaseFirestore
          .instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      // Convert Firestore data to Group object
      group = Group.fromSnap(groupDoc);
      setState(() {});
    } catch (e) {
      print('Error fetching group data: $e');
    }
  }

  void _updatePostsStream() {
    postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('groupId', isEqualTo: widget.groupId)
        .snapshots();
  }

  Future<int> _calculateTotalPosts() async {
    QuerySnapshot<Map<String, dynamic>> postsSnapshot = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('groupId', isEqualTo: widget.groupId)
        .get();
    return postsSnapshot.docs.length;
  }

  Future<void> _updateTotalPosts(int totalPosts) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({'totalPosts': totalPosts});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileScreenLayout(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          elevation: 0,
          title: null, // No title in the AppBar
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          actions: [
            // Add the home icon button
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileScreenLayout(),
                ),
              ),
            ),
          ],
        ),
        drawer: AppDrawer(
          searchQueryController: widget.searchQueryController,
          onGroupTap: (groupId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupFeedScreen(
                  groupId: groupId,
                  searchQueryController: widget.searchQueryController,
                ),
              ),
            );
          },
          createGroupCallback: _goToCreateGroup,
          searchQuery: '',
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Background Image
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 270.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/groupCover.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Positioned Group Image at the bottom
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 180.0,
                        height: 180.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 7.0,
                          ),
                        ),
                        child: group.groupImage.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  group.groupImage,
                                  width: 160.0,
                                  height: 160.0,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 50.0,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
                isCurrentUserAdmin
                    ? IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupSettingsScreen(
                                groupId: widget.groupId,
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox(height: 20.0),

                // Group Title
                Container(
                  width: width > 600 ? 600 : null,
                  child: Column(
                    children: [
                      Text(
                        group.groupName,
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Members
                          Container(
                            width: 80,
                            height: 80,
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Members',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text(
                                          '...',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      int totalUsers = (snapshot.data?['admins']
                                                  as List)
                                              .length +
                                          (snapshot.data?['members'] as List)
                                              .length;
                                      return Text(
                                        '$totalUsers',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                              width:
                                  50), // Optional: Adjust the spacing between Members and Posts

                          // Posts
                          Container(
                            width: 80,
                            height: 80,
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Posts',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  FutureBuilder<int>(
                                    future: _calculateTotalPosts(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text(
                                          '...',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      int totalPosts = snapshot.data ?? 0;
                                      return Text(
                                        '$totalPosts',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  group.description,
                  style: TextStyle(
                    color:
                        group.privacy == 'Private' ? Colors.grey : Colors.black,
                    fontStyle: group.privacy == 'Private'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),

                // Join and Leave Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Join/Leave Button
                      Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            _handleJoinLeaveButton();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: isCurrentUserMemberOrAdmin
                                ? Colors.grey
                                : kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isCurrentUserMemberOrAdmin ? 'Leave' : 'Join',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),

                      Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            _showInviteDialog(); // Call function to show invite dialog
                          },
                          style: ElevatedButton.styleFrom(
                            primary: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Invite',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.0),

                // StreamBuilder or Text for Posts
                group.privacy == 'Public'
                    ? Container(
                        color: Colors.white,
                        child: StreamBuilder(
                          stream: postsStream,
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text('No posts available.'),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (ctx, index) => Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: width > 600 ? width * 0.3 : 0,
                                  vertical: width > 600 ? 15 : 0,
                                ),
                                child: PostCard(
                                  snap: snapshot.data!.docs[index].data(),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        'Private Group\nJoin the group first to see the content',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleJoinLeaveButton() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the current group data
      DocumentSnapshot<Map<String, dynamic>> groupDoc = await FirebaseFirestore
          .instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      // Get the current members and admins arrays
      List<dynamic> members = groupDoc.data()?['members'] ?? [];
      List<dynamic> admins = groupDoc.data()?['admins'] ?? [];

      if (!isCurrentUserMemberOrAdmin) {
        // User is not a member or admin, add to members array
        members.add(uid);

        // Update the members array in Firestore
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({'members': members});

        // Update the membership status
        setState(() {
          isCurrentUserMemberOrAdmin = true;
        });

        // Add the group to the user's 'groups' field
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'groups': FieldValue.arrayUnion([widget.groupId]),
        });
      } else {
        // User is a member or admin, remove from members array
        members.remove(uid);

        // Update the members array in Firestore
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .update({'members': members});

        // Update the membership status
        setState(() {
          isCurrentUserMemberOrAdmin = false;
        });

        // Remove the group from the user's 'groups' field
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'groups': FieldValue.arrayRemove([widget.groupId]),
        });
      }
    } catch (e) {
      print('Error handling Join/Leave button: $e');
    }
  }
}
