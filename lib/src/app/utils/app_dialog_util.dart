import 'package:flutter/material.dart';

// Fungsi showAppDialog tidak diubah dan tetap sama.
Future<void> showAppDialog({
  required BuildContext context,
  required String title,
  required String description,
  required VoidCallback onOkPressed,
  String okButtonText = 'OK',
  VoidCallback? onCancelPressed,
  String? cancelButtonText,
}) async {
  const Color primaryColor = Color(0xFFF68A1E);
  const Color backgroundColor = Color(0xFFF7F5F2);

  final List<Widget> actions = [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onOkPressed();
      },
      child: Text(
        okButtonText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  if (onCancelPressed != null) {
    actions.insert(
      0,
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          onCancelPressed();
        },
        child: Text(
          cancelButtonText ?? 'Batal',
          style: const TextStyle(color: primaryColor),
        ),
      ),
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          description,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: actions,
      );
    },
  );
}

/// Menampilkan dialog kustom untuk memilih sumber media dengan tata letak rata kiri.
/// [context] adalah BuildContext dari widget yang memanggil.
/// [onGalleryTap] adalah fungsi yang dipanggil saat tombol Galeri ditekan.
/// [onCameraTap] adalah fungsi yang dipanggil saat tombol Kamera ditekan.
Future<void> showMediaPickerDialog({
  required BuildContext context,
  required VoidCallback onGalleryTap,
  required VoidCallback onCameraTap,
}) async {
  const Color primaryColor = Color(0xFFF68A1E);
  const Color backgroundColor = Color(0xFFF7F5F2);

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // --- PERUBAHAN: Judul rata kiri ---
        title: const Text(
          'Pilih Sumber Media',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // --- PERUBAHAN: Tombol Galeri rata kiri dengan padding ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  // Menambahkan padding horizontal agar tidak mepet
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // Menyamakan alignment di style agar lebih konsisten
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onGalleryTap();
                },
                child: const Row(
                  // Menghapus alignment di sini agar mengikuti style tombol
                  mainAxisSize: MainAxisSize.min, // Membuat Row seukuran isinya
                  children: [
                    Icon(Icons.photo_library, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Pilih dari Galeri',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // --- PERUBAHAN: Tombol Kamera rata kiri dengan padding ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  // Menambahkan padding horizontal agar tidak mepet
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // Menyamakan alignment di style agar lebih konsisten
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onCameraTap();
                },
                child: const Row(
                  // Menghapus alignment di sini agar mengikuti style tombol
                  mainAxisSize: MainAxisSize.min, // Membuat Row seukuran isinya
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Ambil dari Kamera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Menampilkan dialog konfirmasi kustom dengan ikon, judul, dan pesan di tengah.
/// Dialog ini memiliki tombol Batal di sisi kiri dan tombol OK di sisi kanan.
/// [context] adalah BuildContext dari widget yang memanggil.
/// [icon] adalah IconData yang akan ditampilkan di bagian atas dialog.
/// [title] adalah teks judul dialog.
/// [message] adalah teks deskripsi atau pesan utama.
/// [onOkPressed] adalah fungsi yang akan dipanggil saat tombol OK ditekan.
/// [okButtonText] adalah teks kustom untuk tombol OK (opsional, default 'OK').
/// [onCancelPressed] adalah fungsi yang akan dipanggil saat tombol Batal ditekan (opsional).
/// [cancelButtonText] adalah teks kustom untuk tombol Batal (opsional, default 'Batal').
/// [iconColor] adalah warna untuk ikon (opsional, default oranye).
Future<bool> showConfirmationDialog({
  // <-- UBAH 1: Ubah return type ke Future<bool>
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  required VoidCallback onOkPressed,
  String okButtonText = 'OK',
  VoidCallback? onCancelPressed,
  String cancelButtonText = 'Batal',
  Color iconColor = const Color(0xFFF68A1E),
}) async {
  const Color primaryColor = Color(0xFFF68A1E);
  const Color backgroundColor = Color(0xFFF7F5F2);

  // showDialog sekarang akan mengembalikan nilai yang kita kirim lewat Navigator.pop()
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Icon(icon, color: iconColor, size: 76),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (onCancelPressed != null) onCancelPressed();
                    Navigator.of(
                      dialogContext,
                    ).pop(false); // <-- UBAH 2: Kirim 'false'
                  },
                  child: Text(cancelButtonText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    onOkPressed();
                    Navigator.of(
                      dialogContext,
                    ).pop(true); // <-- UBAH 3: Kirim 'true'
                  },
                  child: Text(
                    okButtonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  // Jika dialog ditutup tanpa menekan tombol (misal, user tap di luar), result akan null.
  // Kita anggap sebagai 'false'.
  return result ?? false;
}

/// Menampilkan dialog notifikasi sukses kustom.
///
/// Dialog ini menampilkan ikon centang, judul, pesan, dan satu tombol "OK".
/// Cocok untuk memberitahu pengguna bahwa sebuah aksi telah berhasil diselesaikan.
Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String okButtonText = 'Mengerti',
  required VoidCallback onOkPressed,
}) async {
  const Color successColor = Colors.green;
  const Color backgroundColor = Color(0xFFF7F5F2);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16),
            const Icon(
              Icons.check_circle_outline,
              color: successColor,
              size: 76,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        actions: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF68A1E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Tutup dialog dulu, baru jalankan callback
                Navigator.of(dialogContext).pop();
                onOkPressed();
              },
              child: Text(okButtonText),
            ),
          ),
        ],
      );
    },
  );
}
