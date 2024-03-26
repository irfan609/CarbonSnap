import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lcos/constants.dart';
import 'package:lcos/screens/answer_montly.dart';
import 'package:lcos/screens/results_menu.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lcos/Screens/login/login.dart';
import 'package:lcos/Screens/pages/blogs_section.dart';
import 'package:lcos/Screens/pages/home_section.dart';
import 'package:lcos/Screens/pages/maps_section.dart';
import 'package:lcos/models/blogs_model.dart';
import 'package:lcos/responsive/mobile_screen_layout.dart';
import 'package:lcos/screens/about.dart';
import 'package:lcos/screens/leaderboard.dart';
import 'package:lcos/screens/profile_screen.dart';
import 'package:lcos/utils/global_variable.dart';
import 'package:lcos/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../resources/auth_methods.dart';
import '../store.dart';

var userData = {};

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void apiCall() async {
    String? jsonRespose;
    var dio = Dio();
    await dio
        .get('https://us-central1-lcos-app-2e724.cloudfunctions.net/app/blogs',
            options: Options(responseType: ResponseType.plain, headers: {
              'Content-Type': 'application/json;charset=UTF-8',
              'Charset': 'utf-8'
            }))
        .then((response) {
      setState(() {
        jsonRespose = response.data.toString();
      });
    });

    blogPost = blogPostFromJson(jsonRespose!);
  }

  void setResult() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User currentUser = _auth.currentUser!;
    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    results = userSnap['result'];
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  void initState() {
    apiCall();
    getData();
    setResult();
    super.initState();
  }

  int _bottomNavIndex = 0;
  List<IconData> iconList = [
    Icons.home_outlined,
    Icons.map,
    Icons.newspaper,
    Icons.person_outline,
  ];

  final List<String> appTitle = [
    'CarbonSnap',
    'Explore local events',
    'Today News',
    'Profile',
  ];

  final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Maps(),
    const Blogs(),
    ProfileScreen(
      uid: FirebaseAuth.instance.currentUser!.uid,
      isSearch: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SafeArea(
        child: DrawerWidget(),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kPrimaryColor),
        elevation: 0,
        title: Text(
          appTitle[_bottomNavIndex],
          style: const TextStyle(color: Colors.black, fontSize: 19),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(child: _widgetOptions.elementAt(_bottomNavIndex)),
      // Only show FloatingActionButton if not on the second page (Local Events)
      floatingActionButton: _bottomNavIndex != 1
          ? FloatingActionButton(
              child: ImageIcon(
                AssetImage("assets/images/logoicon.png"),
                color: kPrimaryColor,
                size: 40,
              ),
              backgroundColor: kBackgroundColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileScreenLayout(),
                ),
              ),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1321),
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.black,
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Local Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Today News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _url = 'https://forms.gle/MQ9Dzu2CvXAYbUsw7';

  void _launchURL() async {
    if (!await launchUrl(Uri.parse(_url))) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: const Color(0xFF0D1321),
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          userData['photoUrl'],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['username'],
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FirebaseAuth.instance.currentUser!.email!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 1.1, color: Colors.black),
                  buildMenuItem(
                      text: 'Leaderboard',
                      icon: Icons.leaderboard_outlined,
                      onClicked: () {
                        selectedItem(context, 2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderBoard(),
                          ),
                        );
                      }),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Your Emission',
                    icon: Icons.gas_meter_outlined,
                    onClicked: () {
                      selectedItem(context, 3);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YourEmission(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Answer Monthly Questions',
                    icon: Icons.delete_outline,
                    onClicked: () async {
                      User currentUser = _auth.currentUser!;
                      await _collectionReference.doc(currentUser.uid).set(
                        {'responses': []},
                        SetOptions(
                          merge: true,
                        ),
                      );

                      // Navigate to AnswerMonth screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnswerMonth(user: currentUser),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Give Feedback',
                    icon: Icons.feedback_outlined,
                    onClicked: () {
                      _launchURL();
                      selectedItem(context, 1);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 1.1, color: Colors.black),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'About',
                    icon: Icons.help_center_outlined,
                    onClicked: () {
                      selectedItem(context, 3);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const About(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'SignOut',
                    icon: Icons.exit_to_app_outlined,
                    onClicked: () async {
                      FirebaseAuth.instance.signOut();
                      await AuthMethods().signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LogScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() => InkWell(
        onTap: () {},
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/lcos-banner.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20)
              .add(const EdgeInsets.symmetric(vertical: 40)),
          child: const SizedBox(height: 30),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    Color color = Colors.green.shade300;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(text, style: TextStyle(color: color, fontSize: 18)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        break;
      case 1:
        break;

      default:
        break;
    }
  }
}
