import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  static Future<List<Map<String, dynamic>>> searchGroups(String query) async {
    try {
      // Your Firestore query logic here based on the search query
      // For example, query groups collection where groupName contains the query
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupName', isGreaterThanOrEqualTo: query)
          .where('groupName', isLessThan: query + 'z') // Adjust as needed
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error searching groups: $e');
      return [];
    }
  }
}