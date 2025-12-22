import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleSignInPlatformAdapter {
  Future<firebase_auth.UserCredential?> signIn();
  Future<void> signOut();
}

class GoogleSignInMobileAdapter implements GoogleSignInPlatformAdapter {
  GoogleSignInMobileAdapter()
      : _google = GoogleSignIn(
          scopes: const ['email', 'profile'],
        );

  final GoogleSignIn _google;

  @override
  Future<firebase_auth.UserCredential?> signIn() async {
    final account = await _google.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _google.signOut();
    await firebase_auth.FirebaseAuth.instance.signOut();
  }
}

/// Google Sign In không được hỗ trợ trên macOS
/// vì cần entitlement network.server mà Apple không chấp nhận
class GoogleSignInMacAdapter implements GoogleSignInPlatformAdapter {
  GoogleSignInMacAdapter({required String? clientId});

  @override
  Future<firebase_auth.UserCredential?> signIn() async {
    throw UnsupportedError(
      'Google Sign In is not supported on macOS. '
      'Please use iOS or Android version of the app.',
    );
  }

  @override
  Future<void> signOut() async {
    // No-op on macOS
  }
}

GoogleSignInPlatformAdapter createGoogleAdapter({
  String? macDesktopClientId,
}) {
  if (Platform.isMacOS) {
    return GoogleSignInMacAdapter(clientId: macDesktopClientId);
  }
  return GoogleSignInMobileAdapter();
}
