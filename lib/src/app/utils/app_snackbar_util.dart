import 'package:flutter/material.dart';

/// Menampilkan SnackBar kustom yang konsisten di seluruh aplikasi.
///
/// [context] adalah BuildContext dari widget yang memanggil.
/// [message] adalah pesan yang akan ditampilkan di dalam SnackBar.
void showAppSnackbar({
  required BuildContext context,
  required String message,
}) {
  // Hapus SnackBar yang mungkin sedang tampil untuk menghindari tumpukan notifikasi
  ScaffoldMessenger.of(context).clearSnackBars();

  // Tampilkan SnackBar yang baru dengan desain kustom
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // Konten utama, yaitu teks pesan dengan warna putih agar kontras
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      ),
      // Warna latar belakang kustom sesuai permintaan
      backgroundColor: const Color(0xFF404343),
      // Bentuk dengan sudut yang sedikit membulat
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      // Perilaku 'floating' agar tidak menempel di bagian bawah layar
      behavior: SnackBarBehavior.floating,
      // Beri sedikit margin agar ada jarak dari tepi layar
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    ),
  );
}
