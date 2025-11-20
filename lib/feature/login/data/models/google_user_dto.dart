import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vos_flutter/feature/login/domain/models/user.dart';

/// DTO (Data Transfer Object) cho Google User
/// Nằm trong Data layer, chịu trách nhiệm:
/// - Parse từ Firebase User
/// - Convert sang Domain Model (User)
/// - Serialize/Deserialize cho local storage
class GoogleUserDto {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? idToken;
  final DateTime? createdAt;

  GoogleUserDto({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.idToken,
    this.createdAt,
  });

  /// Factory constructor: Tạo từ Firebase User
  factory GoogleUserDto.fromFirebaseUser(
    firebase_auth.User firebaseUser,
    String? idToken,
  ) {
    return GoogleUserDto(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      photoURL: firebaseUser.photoURL,
      idToken: idToken,
      createdAt: DateTime.now(),
    );
  }

  /// Factory constructor: Tạo từ JSON (cho local storage)
  factory GoogleUserDto.fromJson(Map<String, dynamic> json) {
    return GoogleUserDto(
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

  /// Factory constructor: Tạo từ Domain Model
  /// Chuyển đổi từ Domain layer → Data layer
  factory GoogleUserDto.fromDomain(User user, {String? idToken}) {
    return GoogleUserDto(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoUrl,
      idToken: idToken,
      createdAt: DateTime.now(),
    );
  }

  /// Convert sang JSON (cho local storage)
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

  /// Convert DTO → Domain Model
  /// Đây là bước quan trọng: Data layer → Domain layer
  User toDomain() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoURL,
    );
  }

  /// Factory constructor: Tạo Domain Model từ DTO
  /// (Cách khác, nhưng toDomain() rõ ràng hơn)
  static User fromDtoToDomain(GoogleUserDto dto) {
    return dto.toDomain();
  }
}