// ignore_for_file: undefined_getter, undefined_method, new_with_undefined_constructor_default, await_only_futures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('=== AuthService.signInWithGoogle START ===');
      debugPrint('📱 Initiating Google Sign-In...');
      
      final googleUser = await _googleSignIn.signIn();
      debugPrint('✓ Google account picker returned: ${googleUser?.email}');

      if (googleUser == null) {
        debugPrint('❌ Google Sign-In was cancelled by user');
        throw Exception('Google Sign-In was cancelled');
      }

      debugPrint('🔑 Fetching Google authentication tokens...');
      final googleAuth = await googleUser.authentication;
      debugPrint('✓ Got access token: ${googleAuth.accessToken?.substring(0, 20)}...');
      debugPrint('✓ Got ID token: ${googleAuth.idToken?.substring(0, 20)}...');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔐 Signing in to Firebase with Google credential...');
      final result = await _firebaseAuth.signInWithCredential(credential);
      debugPrint('✓ Firebase authentication SUCCESS');
      debugPrint('✓ Firebase User: ${result.user?.email}');
      debugPrint('✓ User UID: ${result.user?.uid}');
      debugPrint('=== AuthService.signInWithGoogle SUCCESS ===');
      
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      throw Exception('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Google Sign-In Error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔓 Signing out from Google...');
      await _googleSignIn.signOut();
      debugPrint('🔓 Signing out from Firebase...');
      await _firebaseAuth.signOut();
      debugPrint('✓ Sign out SUCCESS');
    } catch (e) {
      debugPrint('❌ Sign Out Error: $e');
      throw Exception('Sign Out Error: $e');
    }
  }

  User? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    debugPrint('📊 getCurrentUser: ${user?.email ?? "null"}');
    return user;
  }
}