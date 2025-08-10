// lib/utils/shared_preferences.dart
// Nama file disesuaikan dengan path import, namun isi kelas tetap sama.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  // Menyimpan data user (dalam format Map) ke cache lokal.
  // Data diubah menjadi string JSON sebelum disimpan.
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Kunci 'user_data' digunakan untuk menyimpan dan mengambil data.
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Mengambil data user dari cache lokal.
  // Mengembalikan Map jika data ada, atau null jika tidak ada.
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      // Jika data ada, ubah kembali dari string JSON ke Map.
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Menghapus data user dari cache (berguna saat logout).
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // --- PERBAIKAN ---
    // Kunci yang dihapus harus sama dengan kunci yang digunakan untuk menyimpan.
    // Mengubah 'userData' menjadi 'user_data'.
    await prefs.remove('user_data');
    print('User data cache cleared!');
  }
}
