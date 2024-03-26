import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String groupName;
  final String groupImage;
  final String description;
  final dynamic users;
  final String privacy;

  const Group({
    required this.id, 
    required this.groupName,
    required this.groupImage,
    required this.description,
    required this.users,
    required this.privacy,
  });

  static Group fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Group(
      groupName: snapshot["groupName"],
      groupImage: snapshot["groupImage"],
      description: snapshot["description"],
      users: snapshot["users"],
      privacy: snapshot["privacy"],
      id: snapshot["id"],
    );
  }


  Map<String, dynamic> toJson() => {
        "groupName": groupName,
        "groupImage": groupImage,
        "users": users,
        "privacy": privacy,
        "id": id
      };
}
