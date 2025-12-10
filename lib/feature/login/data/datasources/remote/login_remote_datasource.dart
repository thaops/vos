import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/utils/file_logger.dart';
import 'package:vos_flutter/feature/login/data/datasources/remote/google_sign_in_adapter.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';

abstract class LoginRemoteDataSource {
  Future<ApiResult<User>> signInWithGoogle();
  Future<ApiResult<User>> checkAuthState();
  Future<ApiResult<void>> signOut();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignInPlatformAdapter _googleAdapter;

  LoginRemoteDataSourceImpl({
    required GoogleSignInPlatformAdapter googleAdapter,
  }) : _googleAdapter = googleAdapter;

  @override
  Future<ApiResult<User>> signInWithGoogle() async {
    await FileLogger.log('[Google Sign In] Starting sign in process...');
    await FileLogger.log('[Google Sign In] Platform: ${Platform.operatingSystem}');
    
    try {
      final userCredential = await _googleAdapter.signIn();
      final firebaseUser = userCredential?.user;

      if (firebaseUser == null) {
        await FileLogger.log('[Google Sign In] ERROR: Firebase user is NULL');
        return ApiResult.error('Google sign in cancelled or failed');
      }

      await FileLogger.log('[Google Sign In] Firebase sign in SUCCESS - User: ${firebaseUser.email}');
      await FileLogger.log('[Google Sign In] Getting ID token...');
      final idToken = await firebaseUser.getIdToken();
      
      await FileLogger.log('[Google Sign In] Converting to domain model...');
      final dto = GoogleUserDto.fromFirebaseUser(firebaseUser, idToken);
      final domainUser = dto.toDomain();

      await FileLogger.log('[Google Sign In] ✅ Sign in completed successfully!');
      return ApiResult.success(domainUser);
    } catch (e, stackTrace) {
      await FileLogger.logError(e, stackTrace, context: 'Google Sign In failed');
      await FileLogger.log('[Google Sign In] ❌ Sign in failed with error: $e');
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
      await _googleAdapter.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.error('Sign out failed: $e');
    }
  }
}
