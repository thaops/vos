class GoogleUserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? idToken;
  final DateTime? createdAt;

  GoogleUserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.idToken,
    this.createdAt,
  });

  factory GoogleUserModel.fromFirebaseUser({
    required String uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? idToken,
  }) {
    return GoogleUserModel(
      uid: uid,
      displayName: displayName,
      email: email,
      photoURL: photoURL,
      idToken: idToken,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'idToken': idToken,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory GoogleUserModel.fromJson(Map<String, dynamic> json) {
    return GoogleUserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
      idToken: json['idToken'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
