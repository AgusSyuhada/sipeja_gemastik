import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/repository/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // Controllers untuk setiap input field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State untuk UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  // --- Fungsi untuk mengubah state UI ---
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void setAgreeToTerms(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fungsi utama untuk registrasi.
  /// Mengembalikan null jika sukses, atau pesan error (String) jika gagal.
  Future<String?> register() async {
    // Validasi input
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return 'Semua kolom harus diisi';
    }
    if (passwordController.text != confirmPasswordController.text) {
      return 'Kata sandi dan konfirmasi tidak cocok';
    }
    if (!_agreeToTerms) {
      return 'Anda harus menyetujui Syarat & Ketentuan serta Kebijakan Privasi';
    }

    _setLoading(true);

    try {
      // 1. Buat pengguna di Firebase Auth
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (user != null) {
        // 2. Simpan data tambahan ke Realtime Database
        await _authRepository.saveInitialUserData(
          uid: user.uid,
          name: nameController.text,
          email: emailController.text,
        );
        _setLoading(false);
        return null; // Sukses
      }

      _setLoading(false);
      return 'Gagal membuat akun, silakan coba lagi.';
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      // Terjemahkan kode error dari Firebase ke pesan yang mudah dimengerti
      if (e.code == 'weak-password') {
        return 'Kata sandi terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email ini sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return 'Terjadi kesalahan. Coba lagi.';
    } catch (e) {
      _setLoading(false);
      return 'Registrasi gagal: ${e.toString()}';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
