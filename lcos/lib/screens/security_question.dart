import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class SecurityQuestionPage extends StatefulWidget {
  final String uid;
  final Function(String) onSecurityQuestionSet;

  SecurityQuestionPage(
      {required this.uid, required this.onSecurityQuestionSet});

  @override
  _SecurityQuestionPageState createState() => _SecurityQuestionPageState();
}

class _SecurityQuestionPageState extends State<SecurityQuestionPage> {
  late TextEditingController answer1Controller;
  late TextEditingController answer2Controller;
  late bool hasAnsweredBefore;

  @override
  void initState() {
    super.initState();
    answer1Controller = TextEditingController();
    answer2Controller = TextEditingController();
    hasAnsweredBefore = false;
    fetchExistingAnswers();
  }

  void fetchExistingAnswers() async {
    // Retrieve existing answers from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        Map<String, dynamic>? securityAnswers =
            userData['securityAnswer'] as Map<String, dynamic>?;

        if (securityAnswers != null) {
          setState(() {
            answer1Controller.text = securityAnswers['question1'] ?? '';
            answer2Controller.text = securityAnswers['question2'] ?? '';
            hasAnsweredBefore = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SecurityQuestionInput(
              question: 'What is your primary school name?',
              controller: answer1Controller,
              hasAnsweredBefore: hasAnsweredBefore,
            ),
            SizedBox(height: 12),
            SecurityQuestionInput(
              question: 'What is your pet name?',
              controller: answer2Controller,
              hasAnsweredBefore: hasAnsweredBefore,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Get answers from the controllers
                String answer1 = answer1Controller.text;
                String answer2 = answer2Controller.text;

                // Store answers in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .set({
                  'securityAnswer': {
                    'question1': answer1,
                    'question2': answer2,
                  },
                }, SetOptions(merge: true));

                // Pass a success message or perform other actions if needed
                print('Security Questions Set Successfully');

                // Pass the security question back to AccountSettingsPage
                widget.onSecurityQuestionSet(
                    'Security Questions Set Successfully');

                // Close the SecurityQuestionPage and go back to AccountSettingsPage
                Navigator.pop(context);
              },
              child: Text('Set Security Questions'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityQuestionInput extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  final bool hasAnsweredBefore;

  SecurityQuestionInput({
    required this.question,
    required this.controller,
    required this.hasAnsweredBefore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: hasAnsweredBefore ? Colors.grey[200] : null,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
