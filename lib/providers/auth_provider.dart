import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription? _authSub;

  AuthProvider() {
    _authSub = _authService.authStateChanges.listen((user) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get userEmail => _authService.userEmail;

  Future<bool> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  Future<bool> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    return await _authService.updatePassword(email, newPassword);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
