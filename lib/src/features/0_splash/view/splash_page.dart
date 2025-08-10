import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    // Menggunakan listener untuk memantau perubahan status otentikasi
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      // Menunggu sebentar untuk efek splash screen
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return; // Pastikan widget masih ada di tree

        // Batalkan listener setelah digunakan untuk menghindari memory leak
        _authSubscription.cancel();

        if (user == null) {
          // Jika tidak ada user yang login, arahkan ke halaman login
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Jika ada user yang login, arahkan ke halaman utama
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  void dispose() {
    // Pastikan untuk membatalkan listener saat widget dihancurkan
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    child: Image.asset(
                      'assets/images/sipeja_logo_vertical.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'GEMASTIK 2025',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
