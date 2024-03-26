import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lcos/screens/create_group.dart';
import 'package:lcos/screens/dashboard.dart';
import 'package:lcos/screens/group_feed_screen.dart';
import 'package:lcos/screens/socmed_drawer.dart';
import 'package:lcos/utils/colors.dart';
import 'package:lcos/utils/global_variable.dart';
import 'package:lcos/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  final TextEditingController searchQueryController;

  const FeedScreen({Key? key, required this.searchQueryController})
      : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;

  @override
  void initState() {
    super.initState();
    _updatePostsStream(); // Initial update
  }

  void _updatePostsStream() {
    postsStream = FirebaseFirestore.instance.collection('posts').snapshots();
  }

  void _goToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(),
      ),
    );
  }

  void _handleGroupTap(String groupId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GroupFeedScreen(
          groupId: groupId,
          searchQueryController: widget.searchQueryController,
        ),
      ),
    );
  }

  void _goToProfileScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const Dashboard(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press
        _goToProfileScreen();
        // Do not allow the default system back button behavior
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Green Community',
            style: GoogleFonts.rochester(color: Colors.white, fontSize: 30),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          actions: [],
        ),
        drawer: AppDrawer(
          searchQueryController: widget.searchQueryController,
          onGroupTap: _handleGroupTap,
          createGroupCallback: _goToCreateGroup,
          searchQuery: '',
        ),
        body: StreamBuilder(
          stream: postsStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
