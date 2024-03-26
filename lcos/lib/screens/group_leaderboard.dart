import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/providers/user_provider.dart';
import 'package:provider/provider.dart';

class GroupLeaderBoard extends StatefulWidget {
  const GroupLeaderBoard({Key? key}) : super(key: key);

  @override
  _GroupLeaderBoardState createState() => _GroupLeaderBoardState();
}

class _GroupLeaderBoardState extends State<GroupLeaderBoard> {
  String? _selectedGroup;
  String _selectedSortOption = 'Co2 Reduction';

  late Future<List<String>> userGroupsFuture;
  late Future<Map<String, String>> groupNamesFuture;

  @override
  void initState() {
    super.initState();
    userGroupsFuture = fetchUserGroups();
    groupNamesFuture = fetchGroupNames();
  }

  Future<List<String>> fetchUserGroups() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    List<String> userGroups =
        await userProvider.getUserGroups(userProvider.getUser.uid);

    if (userGroups.isEmpty) {
      // If the user doesn't have any groups, set _selectedGroup to null
      // and display a message in the center of the page
      setState(() {
        _selectedGroup = null;
      });
    } else {
      // If the user has groups, set _selectedGroup to the last group
      // that the user opened in the dropdown
      setState(() {
        _selectedGroup = userGroups.first;
      });
    }

    return userGroups;
  }

  Future<Map<String, String>> fetchGroupNames() async {
    Map<String, String> groupNames = {};
    List<String> userGroups = await userGroupsFuture;

    for (String groupUid in userGroups) {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupUid)
          .get();
      if (groupSnapshot.exists) {
        groupNames[groupUid] = groupSnapshot['groupName'] ?? "Unknown Group";
      }
    }

    return groupNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.green),
        elevation: 0,
        title: const Text(
          'Group Leaderboard 🏆',
          style: TextStyle(color: Colors.black, fontSize: 19),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gpleaderboard.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Display Group and Sort Dropdowns
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FutureBuilder<Map<String, String>>(
                    future: groupNamesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        Map<String, String> groupNames = snapshot.data ?? {};
                        return DropdownButton<String>(
                          value: _selectedGroup,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGroup = newValue;
                            });
                          },
                          items:
                              groupNames.entries.map<DropdownMenuItem<String>>(
                            (MapEntry<String, String> entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            },
                          ).toList(),
                          hint: Text("Select Group"),
                        );
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedSortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSortOption = newValue!;
                      });
                    },
                    items: <String>['Co2 Reduction', 'Points']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text("Select Sort Option"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedGroup == null
                  ? Center(
                      child: Text(
                        "Please join a group in Green Community first.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : FutureBuilder<List<String>>(
                      // Fetch the list of selected group members
                      future: fetchGroupMembers(),
                      builder: (context, membersSnapshot) {
                        if (membersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (membersSnapshot.hasError) {
                          return Text("Error: ${membersSnapshot.error}");
                        }

                        List<String> groupMembers = membersSnapshot.data ?? [];

                        return FutureBuilder<QuerySnapshot>(
                          // Fetch the leaderboard data based on the selected group members
                          future: fetchLeaderboardData(groupMembers),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            var sortedData =
                                _selectedSortOption == 'Co2 Reduction'
                                    ? _sortPercentReduction(snapshot.data!)
                                    : _sortPoints(snapshot.data!);

                            return ListView.builder(
                              itemCount: sortedData.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // return the header
                                  return LeaderBoardItems(
                                    no: '',
                                    name: 'Name',
                                    value:
                                        _selectedSortOption == 'Co2 Reduction'
                                            ? 'Reduction %'
                                            : 'Points',
                                    img: '',
                                    isHeader: true,
                                  );
                                }
                                index -= 1;
                                var rawValue = (sortedData[index][
                                        _selectedSortOption == 'Co2 Reduction'
                                            ? 'percentReduction'
                                            : 'weeklyPoint'] as num)
                                    .toDouble();
                                var parsedValue =
                                    _selectedSortOption == 'Co2 Reduction'
                                        ? (rawValue < 0
                                            ? rawValue
                                                .toStringAsFixed(2)
                                                .substring(1)
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> fetchGroupMembers() async {
    // Fetch the list of selected group members and admins
    if (_selectedGroup != null) {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(_selectedGroup)
          .get();

      if (groupSnapshot.exists) {
        List<String>? members = List<String>.from(groupSnapshot['members']);
        List<String>? admins = List<String>.from(groupSnapshot['admins']);

        // Combine members and admins into a single list
        List<String> allGroupMembers = [
          ...?(members ?? []),
          ...?(admins ?? [])
        ];
        return allGroupMembers;
      }
    }
    return [];
  }

  Future<QuerySnapshot> fetchLeaderboardData(List<String> groupMembers) async {
    // Fetch leaderboard data based on the selected group members
    return await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: groupMembers)
        .get();
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
