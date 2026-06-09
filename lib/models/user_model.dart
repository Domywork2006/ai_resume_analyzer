class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? geminiApiKey;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.geminiApiKey,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      geminiApiKey: map['geminiApiKey'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'geminiApiKey': geminiApiKey,
    };
  }
}
