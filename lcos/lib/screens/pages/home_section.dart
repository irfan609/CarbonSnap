import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lcos/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../store.dart';
import '../../utils/global_variable.dart';
import '../weekly_activities.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:lcos/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:lcos/models/user.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lcos/resources/firestore_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FireStoreMethods _fireStoreMethods = FireStoreMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<bool> isChecked = List.generate(3, (index) => false);
  double percentReduction = 0.0;

  int tsk1 = 0;
  int tsk2 = 0;
  int bonu = 0;

  var userData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await initializeData();

      final model.User user =
          Provider.of<UserProvider>(context, listen: false).getUser;

      // Add real-time listener for user data changes
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((userSnapshot) {
        if (userSnapshot.exists) {
          setState(() {
            userData = userSnapshot.data() ?? {};
            tsk1 = userData['tsk1'] ?? 0;
            tsk2 = userData['tsk2'] ?? 0;
            bonu = userData['bonu'] ?? 0;
            percentReduction = userData['percentReduction'] ?? 0.0;
            loadCheckboxState();
          });
        }
      });
    });
  }

  Future<void> initializeData() async {
    await loadCheckboxState();

    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;

    userData = await _fireStoreMethods.getData(user.uid);

    int userPoints = userData['point'] ?? 0;
    int initialTotalPoint = userPoints + tsk1 + tsk2 + bonu;

    await updatePoints(initialTotalPoint);
  }

  Future<void> loadCheckboxState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (userData['point'] == 0) {
      // Reset all checkboxes if 'point' is 0
      setState(() {
        for (int i = 0; i < isChecked.length; i++) {
          isChecked[i] = false;
        }
      });
    } else {
      // Load checkbox state from SharedPreferences
      setState(() {
        for (int i = 0; i < isChecked.length; i++) {
          isChecked[i] = prefs.getBool('checkbox_$i') ?? false;
        }
      });
    }
  }

  Future<void> saveCheckboxState(int index, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('checkbox_$index', value);
  }

  Future<void> updatePoints([int initialTotalPoint = 0]) async {
    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;

    int totalPoint = initialTotalPoint + tsk1 + tsk2 + bonu;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'point': totalPoint});

    setState(() {});
  }

  Future<int> calculateTotalPoints() async {
    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;

    var userData = await _fireStoreMethods.getData(user.uid);

    int todayPoint = userData['point'] ?? 0;

    Map<String, dynamic> dailyPoint = userData['dailyPoint'] ?? {};

    int totalPoints =
        dailyPoint.values.fold(0, (sum, value) => sum + (value as int));

    totalPoints += todayPoint;
    await updateWeeklyPoint(totalPoints);

    return totalPoints;
  }

  Future<void> updateWeeklyPoint(int totalPoints) async {
    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'weeklyPoint': totalPoints});
  }

  @override
  Widget build(BuildContext context) {
    String cdate = DateFormat("dd MMMM, yyyy").format(DateTime.now());

    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;

    return Scaffold(
      body: results != null
          ? ListView(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['photoUrl'] ??
                          'https://example.com/default_image.jpg'),
                      backgroundColor: Colors.white54,
                      radius: 30,
                    ),
                    title: Text(
                      'Welcome, ${user.username}', // Use the username from the user object
                      style: const TextStyle(
                          color: Color(0xFF0D1321),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    subtitle: Text(
                      cdate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1321),
                      ),
                    ),
                    trailing: Column(
                      children: [
                        FutureBuilder<String>(
                          future: Future.value(userData['point'].toString()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? '0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54,
                                ),
                              );
                            }
                          },
                        ),
                        const Text(
                          'Points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircularPercentIndicator(
                          radius: 79.0,
                          lineWidth: 8.0,
                          animation: true,
                          percent: 1,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                results['result'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34.0,
                                  color: Color.fromARGB(255, 6, 96, 66),
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "tons Co2 / yr",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF61892F),
                                ),
                              ),
                              const Text(
                                "Is your current",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF1D4C4F),
                                ),
                              ),
                              const Text(
                                "carbon footprint",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF1D4C4F),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: const Color.fromARGB(255, 6, 96, 66),
                          addAutomaticKeepAlive: true,
                          animationDuration: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CircularPercentIndicator(
                          radius: 79.0,
                          lineWidth: 8.0,
                          animation: true,
                          percent: 1,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${percentReduction.abs().toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34.0,
                                  color: Color.fromARGB(255, 6, 96, 66),
                                ),
                              ),
                              const Text(
                                "Is your carbon",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF1D4C4F),
                                ),
                              ),
                              Text(
                                percentReduction < 0
                                    ? "reduction than"
                                    : "increasement than",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF1D4C4F),
                                ),
                              ),
                              const Text(
                                "last month",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Color(0xFF1D4C4F),
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: kBackgroundColor,
                          addAutomaticKeepAlive: true,
                          animationDuration: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CircularPercentIndicator(
                    radius: 82.0,
                    lineWidth: 8.0,
                    animation: true,
                    percent: 1, // This is not used in this case
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<int>(
                          future: calculateTotalPoints(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data?.toString() ?? '0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34.0,
                                  color: Color.fromARGB(255, 6, 96, 66),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Is your weekly",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                            color: Color(0xFF1D4C4F),
                          ),
                        ),
                        const Text(
                          "points this week",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                            color: Color(0xFF1D4C4F),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: const Color(0xFF4169E1),
                    addAutomaticKeepAlive: true,
                    animationDuration: 2,
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, bottom: 20, top: 10.0),
                  child: Row(
                    children: const [
                      Text(
                        'Daily Challenge',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.navigate_next_rounded,
                          size: 35, color: Color(0xFF1D4C4F)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, bottom: 20),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(4, 8), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Your Today's task",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 11, 40, 42),
                          ),
                        ),
                        todayTask(dailyTasks['1'], 0),
                        todayTask(dailyTasks['2'], 1),
                        const SizedBox(height: 10),
                        const Text(
                          'Bonus task',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 11, 40, 42),
                          ),
                        ),
                        todayTask(dailyTasks['3'], 2),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, bottom: 0, top: 20.0),
                  child: Row(
                    children: const [
                      Text(
                        'Progress Diary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.navigate_next_rounded,
                          size: 35, color: Color(0xFF1D4C4F)),
                    ],
                  ),
                ),
                // ... (existing code)

                Container(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 0, top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // First Column: Transport and Food
                          InfoContainer(
                            icon: Icons.emoji_transportation,
                            string: 'Transport',
                            bgColor: const Color(0xFFBEE5B0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeeklyActivities(
                                    activityName: 'travel',
                                  ),
                                ),
                              );
                            },
                          ),

                          InfoContainer(
                            icon: Icons.food_bank_outlined,
                            bgColor: const Color(0xFF71BC68),
                            string: 'Food',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeeklyActivities(
                                    activityName: 'food',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Second Column: Shopping and Fuel
                          InfoContainer(
                            icon: Icons.shopping_bag,
                            bgColor: const Color.fromARGB(255, 38, 168, 95),
                            string: 'Shopping',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeeklyActivities(
                                    activityName: 'shopping',
                                  ),
                                ),
                              );
                            },
                          ),

                          InfoContainer(
                            icon: Icons.oil_barrel,
                            bgColor: const Color.fromARGB(255, 6, 96, 66),
                            string: 'Fuel',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeeklyActivities(
                                    activityName: 'fuel',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          : const CircularProgressIndicator(),
    );
  }

  Padding todayTask(String name, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: CheckboxListTile(
        secondary: const Icon(FontAwesomeIcons.clipboardList),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Color(0xFF1D4C4F),
          ),
        ),
        value: isChecked[index],
        checkColor: Colors.white,
        activeColor: const Color.fromARGB(255, 11, 40, 42),
        onChanged: (bool? value) {
          setState(() {
            isChecked[index] = value!;
            updateTaskStates();
          });
        },
      ),
    );
  }

  void updateTaskStates() {
    bool updatedTsk1 = isChecked[0];
    bool updatedTsk2 = isChecked[1];
    bool updatedBonu = isChecked[2];

    tsk1 = updatedTsk1 ? 5 : 0;
    tsk2 = updatedTsk2 ? 5 : 0;
    bonu = updatedBonu ? 10 : 0;

    if (updatedTsk1 && updatedTsk2 && !updatedBonu) {
      taskComplete();
    }

    if (updatedTsk1 && updatedTsk2 && updatedBonu) {
      bonusComplete();
    }

    // Update points when any checkbox changes
    updatePoints();

    // Save checkbox states
    for (int i = 0; i < isChecked.length; i++) {
      saveCheckboxState(i, isChecked[i]);
    }
  }

  void taskComplete() async {
    Dialogs.materialDialog(
      color: Colors.white,
      msg: 'You have gained 10 points',
      title: 'Congratulations, task completed',
      lottieBuilder: LottieBuilder.asset('assets/lottie/points.json'),
      context: context,
      customView: Lottie.asset('assets/lottie/confetti.json'),
      actions: [
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Ok',
          iconData: Icons.done,
          color: Colors.green,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  void bonusComplete() {
    Dialogs.materialDialog(
      color: Colors.white,
      title: 'Wow, Bonus task completed',
      msg: 'You get extra 10 points',
      lottieBuilder: LottieBuilder.asset('assets/lottie/bonus.json'),
      context: context,
      customView: Lottie.asset('assets/lottie/confetti.json'),
      actions: [
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Ok',
          iconData: Icons.done,
          color: Colors.green,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class InfoContainer extends StatefulWidget {
  final IconData icon;
  final String string;
  final void Function()? onTap;
  final Color bgColor;

  const InfoContainer({
    Key? key,
    required this.icon,
    required this.string,
    required this.onTap,
    required this.bgColor,
  }) : super(key: key);

  @override
  State<InfoContainer> createState() => _InfoContainerState();
}

class _InfoContainerState extends State<InfoContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.22,
        width: MediaQuery.of(context).size.width / 2.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              widget.icon,
              size: 50,
              color: Colors.black,
            ),
            Text(
              widget.string,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.bgColor,
        ),
      ),
    );
  }
}
