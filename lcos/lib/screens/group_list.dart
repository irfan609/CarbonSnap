import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lcos/models/group.dart';
import 'dart:async';

class GroupList extends StatefulWidget {
  final TextEditingController searchQueryController;
  final Function(String groupId) onGroupTap;

  GroupList({
    required this.searchQueryController,
    required this.onGroupTap,
    required String searchQuery,
  });

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  late StreamController<String> _searchQueryController;

  @override
  void initState() {
    super.initState();
    _searchQueryController = StreamController<String>();
    widget.searchQueryController.addListener(_onSearchQueryChange);
  }

  void _onSearchQueryChange() {
    _searchQueryController.add(widget.searchQueryController.text.toLowerCase());
  }

  @override
  void dispose() {
    _searchQueryController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _searchQueryController.stream,
      initialData: '',
      builder: (context, snapshot) {
        final searchQuery = snapshot.data ?? '';

        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('groups').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<Group> groups = snapshot.data!.docs
                .map((DocumentSnapshot doc) => Group.fromSnap(doc))
                .where((group) =>
                    group.groupName.toLowerCase().contains(searchQuery))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Groups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...groups.map((group) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(group.groupImage),
                    ),
                    title: Text(group.groupName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Members: ${group.users}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '${group.privacy}',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.blue),
                        ),
                      ],
                    ),
                    onTap: () {
                      widget.onGroupTap(group.id);
                    },
                  );
                }).toList(),
                Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
