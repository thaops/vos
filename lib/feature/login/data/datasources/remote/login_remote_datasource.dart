import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';

abstract class LoginRemoteDataSource {
  Future<ApiResult<User>> signInWithGoogle();
  Future<ApiResult<User>> checkAuthState();
  Future<ApiResult<void>> signOut();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn;

  LoginRemoteDataSourceImpl({required GoogleSignIn googleSignIn})
    : _googleSignIn = googleSignIn;

  @override
  Future<ApiResult<User>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResult.error('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return ApiResult.error('User not found');
      }

      final idToken = await firebaseUser.getIdToken();
      final dto = GoogleUserDto.fromFirebaseUser(firebaseUser, idToken);
      final domainUser = dto.toDomain();

      return ApiResult.success(domainUser);
    } catch (e) {
      return ApiResult.error('Sign in failed: $e');
    }
  }

  @override
  Future<ApiResult<User>> checkAuthState() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return ApiResult.error('No authenticated user');
      }

      final idToken = await firebaseUser.getIdToken();
      final dto = GoogleUserDto.fromFirebaseUser(firebaseUser, idToken);
      final domainUser = dto.toDomain();

      return ApiResult.success(domainUser);
    } catch (e) {
      return ApiResult.error('Check auth state failed: $e');
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.error('Sign out failed: $e');
    }
  }
}
