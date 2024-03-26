import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ResetPassword extends StatefulWidget {
  final String enteredEmail;

  ResetPassword({required this.enteredEmail});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late TextEditingController emailController;
  bool isResendButtonDisabled = false;
  int resendCooldown = 30;
  late Timer? resendCooldownTimer;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.enteredEmail);
    resendEmail(); // Automatically send the email when the page is opened
    startResendCooldown(); // Initialize the timer
  }

  @override
  void dispose() {
    emailController.dispose();

    // Cancel the timer if it's not null
    resendCooldownTimer?.cancel();

    super.dispose();
  }

  void startResendCooldown() {
    resendCooldownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        resendCooldown--;

        if (resendCooldown == 0) {
          isResendButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  void resendEmail() async {
    String email = emailController.text;

    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        setState(() {
          isResendButtonDisabled = true;
          resendCooldown = 30;
        });
        startResendCooldown();
      } catch (e) {
        // Handle errors (e.g., if the email is not registered)
        print('Error sending password reset email: $e');
        // You can display an error message to the user if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We will send you an email \n\n If you do not receive the reset link,\ntry this button',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isResendButtonDisabled ? null : () => resendEmail(),
              child: Text('Resend'),
            ),
            SizedBox(height: 8),
            if (isResendButtonDisabled)
              Text(
                'Please wait for $resendCooldown seconds.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
