import 'dart:convert';
import 'package:lcos/constants.dart';
import 'package:lcos/screens/questions_monthly.dart';
import 'package:lcos/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/screens/dashboard.dart';
import 'package:lcos/screens/questions.dart';
import 'package:lottie/lottie.dart';
import 'package:lcos/utils/global_variable.dart';

class AnswerMonth extends StatefulWidget {
  const AnswerMonth({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  State<AnswerMonth> createState() => _AnswerMonthState();
}

class _AnswerMonthState extends State<AnswerMonth> {
  late String uid;
  var userData = {};
  bool isLoading = false;

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
    setResult();
    getData();
  }

  void setResult() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User currentUser = _auth.currentUser!;
    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    try {
      results = userSnap['result'];
    } catch (e) {
      //showSnackBar(context, e.toString());
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
    }
    setState(() {
      isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
      
    String name = userData['username'] ?? nameStarted;
    nameStarted = name;
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -80,
                    right: -80,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          color: Colors.green),
                    ),
                  ),
                  Positioned(
                    top: -110,
                    right: 190,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(170),
                          color: kBackgroundColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 130),
                      SizedBox(
                        child: Center(
                          child: Text(
                            'Welcome, ' + name,
                            style: GoogleFonts.roboto(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: 100,
                        child: Center(
                          child: Text(
                            'Answer your monthly questionaires',
                            style: GoogleFonts.roboto(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Lottie.asset('assets/lottie/loading.json'),
                      SizedBox(
                        height: 70,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            var userSnap = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .get();
                            var response = userSnap['responses'];
                            if (response.isEmpty) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const QuestionsMonthly(),
                                ),
                              );
                          }
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(10.0),
                            backgroundColor:
                                MaterialStateProperty.all(kPrimaryColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
