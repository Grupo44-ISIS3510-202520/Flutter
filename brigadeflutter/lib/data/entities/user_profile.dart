class UserProfile {
  final String uid;
  final String name;
  final String lastName;
  final String uniandesCode;// numérico
  final String bloodGroup;  // O+, A+, ...
  final String role; // student|professor|administrative
  final String email; 
  const UserProfile({
    required this.uid,
    required this.name,
    required this.lastName,
    required this.uniandesCode,
    required this.bloodGroup,
    required this.role,
    required this.email,
  });
}
