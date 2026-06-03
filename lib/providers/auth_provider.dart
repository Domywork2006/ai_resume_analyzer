import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  AuthProvider() {
    debugPrint('📦 AuthProvider initialized');
    _initializeUser();
  }

  void _initializeUser() {
    debugPrint('🔍 Initializing user from Firebase...');
    user = _authService.getCurrentUser();
    debugPrint('✓ Initialization complete. User: ${user?.email ?? "null"}');
    notifyListeners();
  }

  Future<void> login() async {
    try {
      debugPrint('▶️ AuthProvider.login() called');
      isLoading = true;
      error = null;
      notifyListeners();
      debugPrint('🔔 Notified listeners: isLoading=true');

      debugPrint('▶️ Calling AuthService.signInWithGoogle()...');
      final result = await _authService.signInWithGoogle();
      
      debugPrint('✓ AuthService returned UserCredential');
      debugPrint('✓ UserCredential.user: ${result.user?.email}');
      
      user = result.user;
      debugPrint('✓ AuthProvider.user assigned: ${user?.email}');
      debugPrint('🔔 Notifying listeners about user update...');
      error = null;
    } catch (e) {
      debugPrint('❌ AuthProvider.login() FAILED: $e');
      error = e.toString();
      user = null;
    } finally {
      isLoading = false;
      debugPrint('🔔 Notifying listeners: isLoading=false, user=${user?.email ?? "null"}');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('▶️ AuthProvider.logout() called');
      isLoading = true;
      error = null;
      notifyListeners();

      await _authService.signOut();
      user = null;
      error = null;
      debugPrint('✓ Logout SUCCESS');
    } catch (e) {
      debugPrint('❌ Logout Error: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}