import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repository/auth_repository.dart';
import '../../../../../src/app/config/app_config.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Fungsi utama untuk login dengan pengecekan verifikasi email.
  Future<String?> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return 'Email dan kata sandi tidak boleh kosong';
    }

    _setLoading(true);

    try {
      final user = await _authRepository.signInWithEmail(
        emailController.text,
        passwordController.text,
      );

      const allowedUIDs = [AppConfig.allowedUIDs];

      if (user != null) {
        // --- PERUBAHAN UTAMA DI SINI ---
        // Periksa apakah email pengguna sudah diverifikasi.
        if (!user.emailVerified && !allowedUIDs.contains(user.uid)) {
          // Jika belum, keluarkan pengguna lagi dan beri pesan error.
          await _authRepository.signOut();
          _setLoading(false);
          return 'Email Anda belum diverifikasi. Silakan periksa kotak masuk Anda.';
        }

        // Jika sudah diverifikasi, lanjutkan proses seperti biasa.
        await Future.wait([
          _authRepository.updateUserLoginTimestamp(user.uid),
          _authRepository.fetchAndCacheUserData(user.uid),
        ]);
        _setLoading(false);
        return null; // Sukses
      }

      _setLoading(false);
      return 'Terjadi kesalahan tidak diketahui.';
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _mapFirebaseAuthExceptionMessage(e);
    } catch (e) {
      _setLoading(false);
      return 'Login gagal: ${e.toString()}';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseAuthExceptionMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Kata sandi salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      default:
        return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
