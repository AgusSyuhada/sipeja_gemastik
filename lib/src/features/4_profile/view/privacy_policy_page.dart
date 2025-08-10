// file: lib/features/privacy_policy/view/privacy_policy_page.dart

import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F5F2,
      ), // Warna latar belakang seperti login
      body: SafeArea(
        child: Column(
          children: [
            // Menggunakan AppBar kustom yang konsisten
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 32),

                    // --- PERUBAHAN DI SINI ---
                    // Logo dibungkus dengan widget Center agar tidak terpengaruh oleh stretch
                    Center(
                      child: SizedBox(
                        width: 100, // Ukuran lebar disamakan dengan login
                        child: Image.asset(
                          'assets/images/sipeja_logo_vertical.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64), // Jarak bawah disamakan
                    // Bagian "Tentang Aplikasi SIPEJA"
                    const _InfoSection(
                      title: 'Tentang Aplikasi SIPEJA',
                      content:
                          'SIPEJA adalah aplikasi “Sistem Pelayanan Elektronik Jarak Jauh untuk mempermudah masyarakat dalam mengakses layanan publik secara digital”, yang dikembangkan oleh Dinas Komunikasi dan Informatika Kabupaten X.\n\nAplikasi ini disediakan gratis dan dapat digunakan sebagaimana adanya.',
                    ),
                    const SizedBox(height: 32.0),

                    // Bagian "Pihak Ketiga"
                    const _InfoSection(
                      title: 'Pihak Ketiga',
                      content:
                          'Aplikasi SIPEJA dapat menggunakan layanan pihak ketiga untuk meningkatkan kinerja dan fungsionalitas aplikasi. Layanan ini dapat mengumpulkan data tertentu sesuai kebijakan mereka masing-masing.\n\nPihak ketiga yang mungkin digunakan (jika ada):\n• Google Play Services\n• Firebase (Analytics & Crash Reporting)\n\nKami tidak menjual atau membagikan informasi pribadi Anda kepada pihak ketiga untuk tujuan komersial.',
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk AppBar kustom
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            splashRadius: 25,
          ),
          const Expanded(
            child: Text(
              'Kebijakan Privasi',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper untuk seksi informasi agar tidak duplikasi kode
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          content,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.black,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
