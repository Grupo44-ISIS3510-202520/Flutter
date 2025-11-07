import '../entities/user_profile.dart';

class UserProfileModel {
  factory UserProfileModel.fromEntity(UserProfile e) => UserProfileModel(
    uid: e.uid,
    name: e.name,
    lastName: e.lastName,
    uniandesCode: e.uniandesCode,
    bloodGroup: e.bloodGroup,
    role: e.role,
    email: e.email,
  );

  factory UserProfileModel.fromJson(String uid, Map<String, dynamic> json) =>
      UserProfileModel(
        uid: uid,
        name: (json['name'] ?? '').toString(),
        lastName: (json['lastName'] ?? '').toString(),
        uniandesCode: (json['uniandesCode'] ?? '').toString(),
        bloodGroup: (json['bloodGroup'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
      );
  const UserProfileModel({
    required this.uid,
    required this.name,
    required this.lastName,
    required this.uniandesCode,
    required this.bloodGroup,
    required this.role,
    required this.email,
  });
  final String uid, name, lastName, uniandesCode, bloodGroup, role, email;

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastName': lastName,
    'uniandesCode': uniandesCode,
    'bloodGroup': bloodGroup,
    'role': role,
    'email': email,
  };

  UserProfile toEntity() => UserProfile(
    uid: uid,
    name: name,
    lastName: lastName,
    uniandesCode: uniandesCode,
    bloodGroup: bloodGroup,
    role: role,
    email: email,
  );
}
