import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart'
    as google_sign_in_dartio;

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

class GoogleSignInMacAdapter implements GoogleSignInPlatformAdapter {
  GoogleSignInMacAdapter({required String? clientId})
      : assert(
          clientId != null && clientId.isNotEmpty,
          'macOS desktop clientId is required',
        ),
        _clientId = clientId;

  final String? _clientId;
  GoogleSignIn? _google;

  Future<void> _ensureRegistered() async {
    if (_google != null) return;
    await google_sign_in_dartio.GoogleSignInDart.register(
      clientId: _clientId!,
    );
    _google = GoogleSignIn(
      scopes: const ['email', 'profile'],
    );
  }

  @override
  Future<firebase_auth.UserCredential?> signIn() async {
    await _ensureRegistered();
    final account = await _google!.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    if (auth?.accessToken == null || auth?.idToken == null) return null;

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: auth?.accessToken,
      idToken: auth?.idToken,
    );
    return firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _ensureRegistered();
    await _google!.signOut();
    await firebase_auth.FirebaseAuth.instance.signOut();
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
