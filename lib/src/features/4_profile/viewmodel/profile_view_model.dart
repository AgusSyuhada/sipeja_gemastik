// lib/features/main/viewmodel/profile_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../core/services/shared_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _name = 'Memuat...';
  String get name => _name;

  String _email = 'Memuat...';
  String get email => _email;

  // --- TAMBAHKAN STATE UNTUK AVATAR URL ---
  String _avatarUrl = '';
  String get avatarUrl => _avatarUrl;

  ProfileViewModel() {
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    _setLoading(true);

    // Langkah 1: Muat data dari cache untuk tampilan cepat
    final cachedData = await LocalCacheService.getUserData();
    if (cachedData != null) {
      _name = cachedData['name'] ?? 'Nama tidak tersedia';
      _email = cachedData['email'] ?? 'Email tidak tersedia';
      // --- AMBIL AVATAR DARI CACHE ---
      _avatarUrl = cachedData['avatarUrl'] ?? '';
      notifyListeners();
    }

    // Langkah 2: Ambil data terbaru dari server
    final user = _auth.currentUser;
    if (user != null) {
      final freshData = await _authRepository.fetchAndCacheUserData(user.uid);
      if (freshData != null) {
        _name = freshData['name'] ?? 'Nama tidak tersedia';
        _email = freshData['email'] ?? 'Email tidak tersedia';
        // --- AMBIL AVATAR DARI DATA TERBARU ---
        _avatarUrl = freshData['avatarUrl'] ?? '';
      }
    } else {
      _name = 'Gagal memuat';
      _email = 'Gagal memuat';
      _avatarUrl = '';
    }

    _setLoading(false);
  }

  // ... (Sisa kode tidak berubah)

  Future<String?> logout() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _setLoading(false);
      return null; // Sukses
    } catch (e) {
      _setLoading(false);
      return 'Gagal melakukan logout: ${e.toString()}';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
