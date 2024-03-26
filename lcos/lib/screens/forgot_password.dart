import 'package:flutter/material.dart';
import 'package:lcos/constants.dart';
import 'package:lcos/screens/forgot_reset.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool _isEmailEntered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              onChanged: (value) {
                setState(() {
                  _isEmailEntered = value.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter your email',
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 35),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isEmailEntered
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPassword(
                                enteredEmail: _emailController.text,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    primary: _isEmailEntered ? kBackgroundColor : Colors.grey,
                    onPrimary: Colors.black,
                  ),
                  child: Text('Reset Password'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
