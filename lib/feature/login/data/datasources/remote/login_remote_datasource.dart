import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/common/utils/file_logger.dart';
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
    await FileLogger.log('[Google Sign In] Starting sign in process...');
    await FileLogger.log('[Google Sign In] Platform: ${Platform.operatingSystem}');
    
    try {
      // Log current state
      final currentUserBefore = _googleSignIn.currentUser;
      await FileLogger.log('[Google Sign In] currentUser before sign in: ${currentUserBefore != null ? "EXISTS - ${currentUserBefore.email}" : "NULL"}');
      
      // Trên macOS, thử sign out trước để đảm bảo clean state
      if (Platform.isMacOS && currentUserBefore != null) {
        await FileLogger.log('[Google Sign In] macOS: Found existing user, signing out first...');
        try {
          await _googleSignIn.signOut();
          await FileLogger.log('[Google Sign In] Sign out completed');
        } catch (e, stackTrace) {
          await FileLogger.logError(e, stackTrace, context: 'Sign out before sign in failed');
        }
      }
      
      GoogleSignInAccount? googleUser;
      
      // Trên macOS, thử sign in silently trước (nếu đã có session)
      if (Platform.isMacOS) {
        await FileLogger.log('[Google Sign In] macOS detected, trying signInSilently()...');
        try {
          googleUser = await _googleSignIn.signInSilently();
          await FileLogger.log('[Google Sign In] signInSilently() result: ${googleUser != null ? "SUCCESS - User: ${googleUser.email}" : "NULL"}');
        } catch (e, stackTrace) {
          await FileLogger.logError(e, stackTrace, context: 'signInSilently() failed');
          await FileLogger.log('[Google Sign In] signInSilently() failed, will try signIn()');
        }
      } else {
        // Trên iOS/Android, kiểm tra currentUser trước
        await FileLogger.log('[Google Sign In] Checking currentUser...');
        googleUser = _googleSignIn.currentUser;
        await FileLogger.log('[Google Sign In] currentUser: ${googleUser != null ? "EXISTS - ${googleUser.email}" : "NULL"}');
      }
      
      // Nếu chưa có user, thử sign in interactive
      if (googleUser == null) {
        await FileLogger.log('[Google Sign In] No user found, calling signIn()...');
        await FileLogger.log('[Google Sign In] GoogleSignIn instance: ${_googleSignIn.hashCode}');
        await FileLogger.log('[Google Sign In] GoogleSignIn scopes: ${_googleSignIn.scopes}');
        
        try {
          // Trên macOS, thử với timeout để xem có phải bị hang không
          if (Platform.isMacOS) {
            await FileLogger.log('[Google Sign In] macOS: Calling signIn() with timeout...');
            try {
              googleUser = await _googleSignIn.signIn().timeout(
                const Duration(seconds: 30),
              );
            } on TimeoutException {
              await FileLogger.log('[Google Sign In] signIn() TIMEOUT after 30 seconds');
              googleUser = null;
            }
          } else {
            googleUser = await _googleSignIn.signIn();
          }
          
          await FileLogger.log('[Google Sign In] signIn() returned: ${googleUser != null ? "SUCCESS - User: ${googleUser.email}" : "NULL"}');
          
          // Nếu NULL, log thêm thông tin
          if (googleUser == null && Platform.isMacOS) {
            await FileLogger.log('[Google Sign In] macOS: signIn() returned NULL - user may have cancelled or callback failed');
            await FileLogger.log('[Google Sign In] Checking currentUser immediately after signIn()...');
            final immediateUser = _googleSignIn.currentUser;
            await FileLogger.log('[Google Sign In] currentUser immediately: ${immediateUser != null ? "EXISTS - ${immediateUser.email}" : "NULL"}');
          }
        } catch (e, stackTrace) {
          await FileLogger.logError(e, stackTrace, context: 'signIn() threw exception');
          await FileLogger.log('[Google Sign In] signIn() exception type: ${e.runtimeType}');
          await FileLogger.log('[Google Sign In] signIn() exception: $e');
          // Tiếp tục để kiểm tra currentUser
        }
      }
      
      // Sau khi signIn(), kiểm tra lại currentUser (trường hợp macOS có thể cần)
      if (googleUser == null) {
        await FileLogger.log('[Google Sign In] googleUser is still NULL after signIn()');
        
        // Đợi một chút để đảm bảo callback được xử lý (macOS)
        if (Platform.isMacOS) {
          await FileLogger.log('[Google Sign In] Waiting 500ms for macOS callback...');
          await Future.delayed(const Duration(milliseconds: 500));
          
          await FileLogger.log('[Google Sign In] Checking currentUser again after delay...');
          googleUser = _googleSignIn.currentUser;
          await FileLogger.log('[Google Sign In] currentUser after delay: ${googleUser != null ? "EXISTS - ${googleUser.email}" : "NULL"}');
          
          // Thử đợi thêm nếu vẫn null
          if (googleUser == null) {
            await FileLogger.log('[Google Sign In] Still NULL, waiting 1000ms more...');
            await Future.delayed(const Duration(milliseconds: 1000));
            googleUser = _googleSignIn.currentUser;
            await FileLogger.log('[Google Sign In] currentUser after 1000ms: ${googleUser != null ? "EXISTS - ${googleUser.email}" : "NULL"}');
          }
        }
        
        if (googleUser == null) {
          await FileLogger.log('[Google Sign In] ERROR: googleUser is NULL, returning cancelled error');
          return ApiResult.error('Google sign in cancelled');
        }
      }

      await FileLogger.log('[Google Sign In] Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      await FileLogger.log('[Google Sign In] accessToken: ${googleAuth.accessToken != null ? "EXISTS (${googleAuth.accessToken!.substring(0, 20)}...)" : "NULL"}');
      await FileLogger.log('[Google Sign In] idToken: ${googleAuth.idToken != null ? "EXISTS (${googleAuth.idToken!.substring(0, 20)}...)" : "NULL"}');
      
      // Kiểm tra accessToken và idToken
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        await FileLogger.log('[Google Sign In] ERROR: Missing tokens - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');
        return ApiResult.error('Failed to get authentication tokens');
      }
      
      await FileLogger.log('[Google Sign In] Creating Firebase credential...');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FileLogger.log('[Google Sign In] Signing in with Firebase...');
      final firebase_auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        await FileLogger.log('[Google Sign In] ERROR: Firebase user is NULL');
        return ApiResult.error('User not found');
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
      await _googleSignIn.signOut();
      await _auth.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.error('Sign out failed: $e');
    }
  }
}
