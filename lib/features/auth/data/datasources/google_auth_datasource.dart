import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_auth_datasource.g.dart';

@riverpod
GoogleAuthDataSource googleAuthDataSource(GoogleAuthDataSourceRef ref) {
  return GoogleAuthDataSource();
}

class GoogleAuthDataSource {
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage;

  GoogleAuthDataSource({GoogleSignIn? googleSignIn, FlutterSecureStorage? secureStorage})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'https://www.googleapis.com/auth/drive.file', 'https://www.googleapis.com/auth/spreadsheets']),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<UserModel?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) throw Exception("No access token obtained");

      final userModel = UserModel(
        uid: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? 'Usuário',
        photoUrl: googleUser.photoUrl,
        accessToken: accessToken,
      );

      await _secureStorage.write(key: 'cached_user', value: jsonEncode(userModel.toJson()));
      return userModel;
    } catch (e) {
      throw Exception("Google Sign In failed: $e");
    }
  }

  Future<UserModel?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) throw Exception("No access token obtained during silent sign-in");

      final userModel = UserModel(
        uid: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? 'Usuário',
        photoUrl: googleUser.photoUrl,
        accessToken: accessToken,
      );

      await _secureStorage.write(key: 'cached_user', value: jsonEncode(userModel.toJson()));
      return userModel;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.delete(key: 'cached_user');
  }

  Future<UserModel?> getStoredUser() async {
    final cached = await _secureStorage.read(key: 'cached_user');
    if (cached != null) {
      try {
        return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
