import 'package:flutter/material.dart';
import 'package:lcos/Screens/login/components/login_form.dart';
import 'package:lcos/Screens/login/components/register_form.dart';
import 'package:lcos/constants.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  Animation<double>? containerSize;
  AnimationController? animationController;
  Duration animationDuration = const Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double viewInset = MediaQuery.of(context).viewInsets.bottom;

    double defaultLoginSize = size.height - (size.height * 0.2);
    double defaultRegisterSize = size.height - (size.height * 0.15);

    containerSize = Tween<double>(
      begin: size.height * 0.1,
      end: defaultRegisterSize,
    ).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.linear,
    ));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Login Form
            Visibility(
              visible: isLogin,
              child: LoginForm(
                isLogin: isLogin,
                animationDuration: animationDuration,
                size: size,
                defaultLoginSize: defaultLoginSize,
              ),
            ),

            // Register Container
            AnimatedBuilder(
              animation: animationController!,
              builder: (context, child) {
                if (viewInset == 0 && isLogin) {
                  return buildRegisterContainer();
                } else if (!isLogin) {
                  return buildRegisterContainer();
                }

                // Returning empty container to hide the widget
                return Container();
              },
            ),

            // Register Form
            RegisterForm(
              isLogin: isLogin,
              animationDuration: animationDuration,
              size: size,
              defaultLoginSize: defaultRegisterSize,
              onBack: () {
                animationController!.reverse();
                setState(() {
                  isLogin = !isLogin;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedOpacity(
        opacity: isLogin ? 1.0 : 0.0,
        duration: animationDuration * 5,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
              color: Colors.white),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: !isLogin
                ? null
                : () {
                    animationController!.forward();

                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
            child: isLogin
                ? const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: kPrimaryColor, fontSize: 16),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
