import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/screens/group_leaderboard.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  int _currentIndex = 0;
  String _pointsField = 'percentReduction'; // Default field is percentReduction

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.green),
        elevation: 0,
        title: const Text(
          'Leaderboard 🏆',
          style: TextStyle(color: Colors.black, fontSize: 19),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/leaderboardbg.jpg'),
            fit: BoxFit
                .cover, // You can adjust the fit based on your requirement
          ),
        ),
        child: Column(
          children: [
            Flexible(
              child: FutureBuilder(
                future: _getCurrentQuery(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var sortedData = _currentIndex == 0
                      ? _sortPercentReduction(snapshot.data! as QuerySnapshot)
                      : _sortPoints(snapshot.data! as QuerySnapshot);

                  return ListView.builder(
                    itemCount: sortedData.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // return the header
                        return LeaderBoardItems(
                          no: '',
                          name: 'Name',
                          value: _currentIndex == 0 ? 'Reduction %' : 'Points',
                          img: '',
                          isHeader: true,
                        );
                      }
                      index -= 1;
                      var rawValue =
                          (sortedData[index][_pointsField] as num).toDouble();
                      var parsedValue = _currentIndex == 0
                          ? (rawValue < 0
                              ? rawValue.toStringAsFixed(2).substring(1)
                              : '-' + rawValue.toStringAsFixed(2))
                          : rawValue.toStringAsFixed(0);

                      return LeaderBoardItems(
                        isHeader: false,
                        no: (index + 1).toString() + '.',
                        name: sortedData[index]['username'],
                        value: parsedValue,
                        img: sortedData[index]['photoUrl'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            if (index == 2) {
              // Navigate to GroupLeaderBoard page when 'Group' tab is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupLeaderBoard(),
                ),
              );
            } else {
              _currentIndex = index;
              _pointsField = index == 0 ? 'percentReduction' : 'weeklyPoint';
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Co2 Reduction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Points',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Group',
          ),
        ],
      ),
    );
  }

  Future<QuerySnapshot> _getCurrentQuery() async {
    if (_currentIndex == 0) {
      return await FirebaseFirestore.instance
          .collection('users')
          .orderBy('percentReduction')
          .get();
    } else if (_currentIndex == 1) {
      return await FirebaseFirestore.instance
          .collection('users')
          .orderBy('weeklyPoint', descending: true)
          .get();
    } else {
      return await FirebaseFirestore.instance.collection('users').get();
    }
  }

  List<DocumentSnapshot> _sortPercentReduction(QuerySnapshot snapshot) {
    var data = snapshot.docs;
    data.sort((a, b) {
      var aValue = (a['percentReduction'] as num).toDouble();
      var bValue = (b['percentReduction'] as num).toDouble();
      return aValue.compareTo(bValue);
    });
    return data;
  }

  List<DocumentSnapshot> _sortPoints(QuerySnapshot snapshot) {
    var data = snapshot.docs;
    data.sort((a, b) {
      var aValue = (a['weeklyPoint'] as num).toDouble();
      var bValue = (b['weeklyPoint'] as num).toDouble();
      return bValue.compareTo(aValue);
    });
    return data;
  }
}

class LeaderBoardItems extends StatelessWidget {
  const LeaderBoardItems({
    required this.no,
    required this.name,
    required this.value,
    required this.img,
    required this.isHeader,
    Key? key,
  }) : super(key: key);

  final String no;
  final String img;
  final String name;
  final String value;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHeader ? 5 : 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 10),
              child: Text(
                no,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            img != ''
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      img,
                    ),
                    radius: 16,
                  )
                : Container(),
          ],
        ),
        title: Text(
          name,
          style: isHeader
              ? const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )
              : const TextStyle(
                  fontSize: 13,
                ),
        ),
        trailing: Text(
          value,
          style: isHeader
              ? const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )
              : null,
        ),
      ),
    );
  }
}
