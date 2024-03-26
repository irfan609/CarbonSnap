import 'package:flutter/widgets.dart';
import 'package:lcos/models/user.dart';
import 'package:lcos/resources/auth_methods.dart';
import 'package:lcos/resources/firestore_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();
  final FireStoreMethods _firestoreMethods = FireStoreMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<List<String>> getUserGroups(String uid) async {
    try {
      List<String> groups = await _firestoreMethods.getUserGroups(uid);
      return groups;
    } catch (e) {
      // Handle any errors that occurred during the data retrieval
      print('Error getting user groups: $e');
      return [];
    }
  }
}
