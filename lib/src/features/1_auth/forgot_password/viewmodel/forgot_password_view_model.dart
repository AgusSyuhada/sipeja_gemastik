// file: lib/features/auth/viewmodel/forgot_password_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repository/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Mengirim link reset password.
  /// Mengembalikan null jika sukses, atau pesan error (String) jika gagal.
  Future<String?> sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      return 'Silakan masukkan email yang valid';
    }

    _setLoading(true);

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') {
        return 'Email tidak terdaftar.';
      }
      return 'Terjadi kesalahan. Coba lagi.';
    } catch (e) {
      _setLoading(false);
      return 'Gagal mengirim email: ${e.toString()}';
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}