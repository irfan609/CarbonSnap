import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/widgets/post_card.dart';

class ProfileFeed extends StatefulWidget {
  final String uid; // Assuming you pass the userId to fetch posts
  final String postId; // New property for the postId

  const ProfileFeed({Key? key, required this.uid, required this.postId})
      : super(key: key);

  @override
  _ProfileFeedState createState() => _ProfileFeedState();
}

class _ProfileFeedState extends State<ProfileFeed> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;

  @override
  void initState() {
    super.initState();
    postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .where('postId', isEqualTo: widget.postId)
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Feed'),
      ),
      body: StreamBuilder(
        stream: postsStream,
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return const Center(
              child: Text('Error loading data'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              if (snapshot.data!.docs[index].data() == null) {
                // Handle the case where document data is null
                return Container(); // or a placeholder widget
              }

              var postData =
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600
                      ? MediaQuery.of(context).size.width * 0.3
                      : 0,
                  vertical: MediaQuery.of(context).size.width > 600 ? 15 : 0,
                ),
                child: PostCard(
                  snap: postData,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
