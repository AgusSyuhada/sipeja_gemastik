import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../app/config/app_config.dart';
import '../../core/services/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.databaseURL,
  ).ref();

  /// Melakukan sign-in dengan Firebase Authentication.
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return userCredential.user;
  }

  /// Memperbarui timestamp login terakhir pengguna di Realtime Database.
  /// Menggunakan format ISO 8601 UTC.
  Future<void> updateUserLoginTimestamp(String uid) async {
    await _dbRef
        .child('users/$uid/metadata/lastLogin')
        .set(DateTime.now().toUtc().toIso8601String());
  }

  /// Mengambil data pengguna dari Firebase dan menyimpannya ke cache lokal.
  Future<Map<String, dynamic>?> fetchAndCacheUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child('users/$uid').get();
      if (snapshot.exists && snapshot.value != null) {
        final allUserData = Map<String, dynamic>.from(snapshot.value as Map);

        final Map<String, dynamic> combinedData = {};
        if (allUserData['metadata'] is Map) {
          combinedData.addAll(
            Map<String, dynamic>.from(allUserData['metadata']),
          );
        }
        if (allUserData['profile'] is Map) {
          combinedData.addAll(
            Map<String, dynamic>.from(allUserData['profile']),
          );
        }

        if (combinedData.isNotEmpty) {
          // Tetap simpan ke cache untuk sesi berikutnya
          await LocalCacheService.saveUserData(combinedData);
          print(
            'User data (metadata & profile) fetched and cached successfully!',
          );
          // Kembalikan data yang baru diambil
          return combinedData;
        }
      }
      return null; // Kembalikan null jika user tidak ditemukan
    } catch (e) {
      print('Failed to fetch user data from DB: $e');
      return null;
    }
  }

  /// Membuat pengguna baru, kemudian mengirimkan email verifikasi.
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    if (userCredential.user != null) {
      await userCredential.user!.sendEmailVerification();
    }

    return userCredential.user;
  }

  /// Menyimpan data awal dan membuat log pembuatan akun.
  /// Semua timestamp disimpan dalam format ISO 8601 UTC.
  Future<void> saveInitialUserData({
    required String uid,
    required String name,
    required String email,
  }) async {
    // Menggunakan .toUtc() untuk konsistensi zona waktu
    final now = DateTime.now().toUtc().toIso8601String();
    final userRef = _dbRef.child('users/$uid');

    await userRef.set({
      'metadata': {
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': now,
        'lastLogin': now,
        'role': 'user',
      },
      'profile': {'avatarUrl': '', 'bio': ''},
    });

    // [FIXED] Mengubah ServerValue.timestamp menjadi format ISO 8601 UTC
    await userRef.child('logs').push().set({
      'action': 'Account created',
      'timestamp': now,
    });
  }

  /// Mengirim email untuk reset password ke alamat email yang diberikan.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Melakukan sign-out dari Firebase.
  Future<void> signOut() async {
    try {
      // 1. Logout dari Firebase
      await _auth.signOut();
      // 2. Hapus data pengguna dari cache lokal
      await LocalCacheService.clearUserData();
    } catch (e) {
      // Lemparkan kembali error agar bisa ditangkap oleh ViewModel
      print('Error during sign out: $e');
      rethrow;
    }
  }
}
