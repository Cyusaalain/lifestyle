class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final int points;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.points = 0,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      points: data['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'points': points,
    };
  }
}
