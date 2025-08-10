import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:latlong2/latlong.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:provider/provider.dart';
import '../viewmodel/add_report_view_model.dart';
import '../../../../app/utils/app_dialog_util.dart';
import '../../../../app/utils/app_snackbar_util.dart';
import '../../../../app/utils/image_preview_dialog.dart';
// Ganti path ini sesuai struktur folder Anda
import '../../widgets/fullscreen_map_dialog.dart'; // <-- TAMBAHKAN IMPORT INI

class PreviewReportPage extends StatelessWidget {
  const PreviewReportPage({super.key});

  Future<void> _handleSubmit(BuildContext context) async {
    final viewModel = Provider.of<AddReportViewModel>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Hapus SnackBar yang mungkin sedang tampil
    scaffoldMessenger.clearSnackBars();

    // Tampilkan SnackBar dengan gaya kustom saat laporan dikirim
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Mengirim laporan... Mohon jangan tutup aplikasi.',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        // Durasi panjang agar tidak hilang selama proses pengiriman
        duration: const Duration(days: 1),
        // Gaya visual disesuaikan dengan app_snackbar_util.dart
        backgroundColor: const Color(0xFF404343),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
    );

    await viewModel.submitReport();
    scaffoldMessenger.hideCurrentSnackBar();

    if (context.mounted) {
      if (viewModel.errorMessage != null) {
        showAppSnackbar(
          context: context,
          message: "Gagal: ${viewModel.errorMessage}",
        );
      } else {
        await showSuccessDialog(
          context: context,
          title: 'Laporan Terkirim',
          message: 'Terima kasih! Laporan Anda telah berhasil kami terima.',
          onOkPressed: () {
            navigator.popUntil((route) => route.isFirst);
          },
        );
      }
    }
  }

  // --- FUNGSI BARU UNTUK PARSE KOORDINAT ---
  LatLng _parseCoordinates(String coordinates) {
    try {
      final parts = coordinates.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      // Mengembalikan nilai default jika parsing gagal
      return LatLng(0.5071, 101.4478); // Contoh: Lokasi default di Pekanbaru
    }
    // Mengembalikan nilai default jika format tidak sesuai
    return LatLng(0.5071, 101.4478);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddReportViewModel>(
      builder: (context, viewModel, child) {
        // --- AMBIL DAN PARSE KOORDINAT DI SINI ---
        final reportLocation =
            _parseCoordinates(viewModel.koordinatController.text);

        return WillPopScope(
          onWillPop: () async => !viewModel.isSubmitting,
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F5F2),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF4F6F0),
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color(0xFFF4F6F0),
                statusBarIconBrightness: Brightness.dark,
              ),
              title: GestureDetector(
                onTap: viewModel.isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: viewModel.isSubmitting
                          ? Colors.grey
                          : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kembali',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: viewModel.isSubmitting
                            ? Colors.grey
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Visibility(
                  visible: viewModel.isSubmitting,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFF68A1E),
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PREVIEW LAPORAN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mohon periksa kembali detail laporan Anda sebelum mengirim.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoDisplay('Kabupaten/Kota', viewModel.kota),
                  _buildInfoDisplay(
                    'Kecamatan',
                    viewModel.selectedKecamatan ?? '-',
                  ),
                  _buildInfoDisplay(
                    'Kelurahan/Desa',
                    viewModel.selectedKelurahan ?? '-',
                  ),
                  _buildInfoDisplay(
                    'Nama Jalan',
                    viewModel.jalanController.text,
                  ),
                  _buildInfoDisplay(
                    'Koordinat',
                    viewModel.koordinatController.text,
                  ),
                  // --- TAMBAHKAN MAP PREVIEW DI SINI ---
                  if (viewModel.koordinatController.text.isNotEmpty)
                    _buildMapPreview(context, reportLocation),
                  // -------------------------------------
                  if (viewModel.imageFile != null)
                    _buildImagePreview(context, viewModel.imageFile!),
                  _buildInfoDisplay('Dampak', viewModel.dampakController.text),
                  _buildInfoDisplay(
                    'Deskripsi',
                    viewModel.deskripsiController.text,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF474948),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sebelumnya',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isSubmitting
                          ? null
                          : () async {
                              final isConfirmed = await showConfirmationDialog(
                                context: context,
                                icon: Icons.forward_to_inbox_outlined,
                                title: 'Kirim Laporan?',
                                message:
                                    'Pastikan semua data yang Anda masukkan sudah benar sebelum mengirim.',
                                okButtonText: 'Ya, Kirim',
                                cancelButtonText: 'Periksa Lagi',
                                onOkPressed: () {},
                              );

                              if (isConfirmed && context.mounted) {
                                _handleSubmit(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF68A1E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: viewModel.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Kirim Laporan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET BARU UNTUK MAP PREVIEW ---
  Widget _buildMapPreview(BuildContext context, LatLng reportLocation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Koordinat Lokasi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FullscreenMapDialog(
                    initialCenter: reportLocation,
                  );
                },
              );
            },
            child: SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: AbsorbPointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: reportLocation,
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app', // Ganti dengan package name aplikasi Anda
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: reportLocation,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              size: 45,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, File imageFile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Media (Foto)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ImagePreviewDialog(imageFile: imageFile),
              );
            },
            child: Hero(
              tag: 'report_image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}