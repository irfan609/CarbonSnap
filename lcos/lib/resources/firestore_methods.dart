import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/models/post.dart';
import 'package:lcos/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> reportUser(String userName, String userId, String postId) async {
    return await _firestore.collection('report').doc(userId).set({
      'userName': userName,
      'userId': userId,
      'reported': true,
      'postId': postId,
    });
  }

  Future<void> reportComment(
      String userName, String userId, String commentId, String text) async {
    return await _firestore.collection('report').doc(userId).set({
      'userName': userName,
      'userId': userId,
      'reported': true,
      'commentId': commentId,
      'text': text,
    });
  }

  Future<List<String>> getUserGroups(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('groups')) {
          List<String> groups = List<String>.from(userData['groups']);
          return groups;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting user groups: $e');
      return [];
    }
  }

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    bool isVideo, {
    String? groupId,
  }) async {
    String res = "Some error occurred";
    try {
      String mediaUrl;

      if (isVideo) {
        mediaUrl = await StorageMethods()
            .uploadVideoToStorage('posts', file, 'video.mp4');
      } else {
        mediaUrl =
            await StorageMethods().uploadImageToStorage('posts', file, true);
      }

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: mediaUrl,
        profImage: profImage,
        isVideo: isVideo,
        groupId: groupId, 
      );

      // Move the list of user groups below the caption
      List<String> userGroups = await getUserGroups(uid);

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPostWithVideo(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
    String videoPath, {
    String? groupId,
  }) async {
    String res = "Some error occurred";
    try {
      String videoUrl =
          await StorageMethods().uploadVideoToStorage('posts', file, videoPath);
      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: videoUrl,
        profImage: profImage,
        isVideo: true,
        groupId: groupId,
      );

      // Move the list of user groups below the caption
      List<String> userGroups = await getUserGroups(uid);

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      throw Exception('Error unfollowing user: $e');
    }
  }

  Future<Map<String, dynamic>> getData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }
}
