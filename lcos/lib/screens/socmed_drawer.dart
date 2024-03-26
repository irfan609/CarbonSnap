import 'package:flutter/material.dart';
import 'package:lcos/screens/group_list.dart';

class AppDrawer extends StatelessWidget {
  final TextEditingController searchQueryController;
  final Function(String groupId) onGroupTap;
  final Function() createGroupCallback;

  AppDrawer({
    required this.searchQueryController,
    required this.onGroupTap,
    required this.createGroupCallback,
    required String searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/groupCover.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchQueryController,
              decoration: InputDecoration(
                hintText: 'Search your group',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: GroupList(
                searchQueryController: searchQueryController,
                onGroupTap: onGroupTap,
                searchQuery: '',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 16, top: 16, right: 16),
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: createGroupCallback,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '+ Create new group',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
