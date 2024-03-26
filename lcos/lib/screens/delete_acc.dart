import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lcos/resources/auth_methods.dart';
import 'package:lcos/screens/login/login.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late TextEditingController passwordController;
  late TextEditingController feedbackController;
  bool isPasswordIncorrect = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    feedbackController = TextEditingController();
  }

  void submitDeleteRequest() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String enteredPassword = passwordController.text;

    // Check the entered password
    bool isPasswordCorrect = await checkPassword(uid, enteredPassword);

    if (isPasswordCorrect) {
      try {
        // Show loading indicator
        showLoadingDialog();

        // Delete document in 'deletedUser' collection
        String feedback = feedbackController.text;
        saveFeedbackAndTimestamp(uid, feedback);

        // Delete all objects in 'posts/$uid/' in Firebase Storage
        await FirebaseStorage.instance.ref().child('posts/$uid/').delete();

        // Delete profile picture in storage
        await FirebaseStorage.instance.ref().child('profilePics/$uid').delete();

        // Delete documents in 'posts' collection with matching 'uid' field
        QuerySnapshot postsQuery = await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid)
            .get();

        // Delete each post in the 'posts' collection
        for (QueryDocumentSnapshot doc in postsQuery.docs) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .delete();
        }

        // Delete document in 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete the user account
        await FirebaseAuth.instance.currentUser!.delete();

        // Navigate to the LogScreen after successful deletion
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LogScreen(),
          ),
        );
      } catch (e) {
        // Handle account deletion error
        print("Error deleting account: $e");
      }
    } else {
      // Password is incorrect, display a message
      setState(() {
        isPasswordIncorrect = true;
      });
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Deleting account..."),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
  }

  Future<bool> checkPassword(String uid, String enteredPassword) async {
    // Implement your logic to check the password against Firebase Auth
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: FirebaseAuth.instance.currentUser!.email!,
              password: enteredPassword);
      return userCredential.user != null;
      // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  void saveFeedbackAndTimestamp(String uid, String feedback) async {
    // Save feedback and timestamp to Firestore in the "deletedUser" collection
    await FirebaseFirestore.instance.collection('deletedUser').doc(uid).set({
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Warning, you are about to delete your account!\nAccount that has been deleted cannot be restored',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(height: 20),
            buildQuestion("Account password", passwordController),
            if (isPasswordIncorrect)
              Text(
                'Incorrect password',
                style: TextStyle(color: Colors.red),
              ),
            buildQuestion("Feedback/Reason (optional)", feedbackController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitDeleteRequest,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestion(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextField(
          controller: controller,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
