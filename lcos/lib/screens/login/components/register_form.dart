import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lcos/resources/auth_methods.dart';
import 'package:lcos/utils/global_variable.dart';
import 'package:lcos/utils/utils.dart';
import '../../../constants.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
    required this.onBack,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;
  final VoidCallback onBack;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    if (_usernameController.text == '') {
      showSnackBar(context, 'Enter user name');
      return;
    }
    nameStarted = _usernameController.text;
    if (_emailController.text == '') {
      showSnackBar(context, 'Enter email');
      return;
    }
    if (_passwordController.text.length < 6) {
      showSnackBar(context, 'Password must be at least 6 characters long');
      return;
    }
    if (_bioController.text == '') {
      showSnackBar(context, 'Enter bio');
      return;
    }

    // set loading to true
    if (_image == null) {
      String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
      );
      if (res == 'sucess') {
        setState(() {
          showSnackBar(context, 'User created successfully');
        });
      } else {
        showSnackBar(context, res);
      }
    } else {
      String res = await AuthMethods().signUpUserWithImage(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          file: _image!);
      if (res == 'sucess') {
        setState(() {
          showSnackBar(context, 'User created successfully');
        });
      } else {
        showSnackBar(context, 'Please try again');
      }
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Handle the back button press
          widget.onBack();
          return false; // Return true to allow back, false to prevent it
        },
        child: AnimatedOpacity(
          opacity: widget.isLogin ? 0.0 : 1.0,
          duration: widget.animationDuration * 5,
          child: Visibility(
            visible: !widget.isLogin,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: widget.size.width,
                height: widget.defaultLoginSize,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                  backgroundColor: Colors.red,
                                )
                              : const CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                      'https://i.stack.imgur.com/l60Hf.png'),
                                  backgroundColor: Colors.red,
                                ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: widget.size.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white, // Change color to white
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: TextField(
                          controller: _usernameController,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person, color: kPrimaryColor),
                            hintText: 'User Name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: widget.size.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white, // Change color to white
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: TextField(
                          controller: _emailController,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email, color: kPrimaryColor),
                            hintText: 'Email',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: widget.size.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white, // Change color to white
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: TextField(
                          controller: _passwordController,
                          cursorColor: kPrimaryColor,
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock, color: kPrimaryColor),
                            hintText: 'Password',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: widget.size.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white, // Change color to white
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: TextField(
                          controller: _bioController,
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.abc, color: kPrimaryColor),
                            hintText: 'Bio',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          const SizedBox(height: 50),
                          InkWell(
                            onTap: () {
                              signUpUser();
                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: widget.size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: const Text(
                                'SIGN-UP',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: widget.onBack,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: widget.size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor.withAlpha(50),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: const Text(
                                'BACK',
                                style: TextStyle(
                                    color: kPrimaryColor, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
