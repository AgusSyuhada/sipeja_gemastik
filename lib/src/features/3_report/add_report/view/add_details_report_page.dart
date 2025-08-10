import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodel/add_report_view_model.dart';
import '../../../../app/utils/app_dialog_util.dart';
import '../../../../app/utils/app_snackbar_util.dart';
import 'preview_report_page.dart';

class AddDetailsPage extends StatelessWidget {
  const AddDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddReportViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F0),
        elevation: 0,
        // --- FIX: Properti ini memastikan tidak ada perubahan warna/bayangan saat scroll ---
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // --- FIX: Mengatur gaya status bar agar konsisten ---
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF4F6F0), // Samakan dengan warna AppBar
          statusBarIconBrightness:
              Brightness.dark, // Ikon (jam, baterai) menjadi gelap
        ),
        title: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Kembali',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- FIX: SizedBox di atas judul dihapus ---
              const Text(
                'TAMBAH LAPORAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Lengkapi Uraian',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Silahkan jelaskan uraian tambahan terhadap jalan yang rusak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildMediaInput(context),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Dampak',
                hint: 'Contoh: Banjir, Kemacetan, dll.',
                controller: viewModel.dampakController,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Deskripsi',
                hint: 'Jelaskan detail laporan Anda di sini...',
                controller: viewModel.deskripsiController,
                maxLines: 5,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: () {
                    final missingFields = <String>[];
                    if (viewModel.imageFile == null) {
                      missingFields.add('Media (Foto)');
                    }
                    if (viewModel.dampakController.text.trim().isEmpty) {
                      missingFields.add('Dampak');
                    }
                    if (viewModel.deskripsiController.text.trim().isEmpty) {
                      missingFields.add('Deskripsi');
                    }

                    if (missingFields.isNotEmpty) {
                      String errorMessage;
                      if (missingFields.length > 1) {
                        final allButLast = missingFields
                            .take(missingFields.length - 1)
                            .join(', ');
                        final last = missingFields.last;
                        errorMessage =
                            'Data $allButLast dan $last belum lengkap. Mohon diisi terlebih dahulu.';
                      } else {
                        errorMessage =
                            'Data ${missingFields.first} belum lengkap. Mohon diisi terlebih dahulu.';
                      }
                      showAppSnackbar(context: context, message: errorMessage);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const PreviewReportPage(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF68A1E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
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
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
            filled: true,
            fillColor: const Color(0xFFF68A1E).withOpacity(0.25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaInput(BuildContext context) {
    return Column(
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
        Consumer<AddReportViewModel>(
          builder: (context, viewModel, child) {
            return GestureDetector(
              onTap: () {
                showMediaPickerDialog(
                  context: context,
                  onGalleryTap: () => viewModel.pickImage(ImageSource.gallery),
                  onCameraTap: () => viewModel.pickImage(ImageSource.camera),
                );
              },
              child: Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFF292A27), width: 1),
                ),
                child: viewModel.imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.black45,
                            size: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ketuk untuk mengambil foto dari\nkamera atau galeri',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      )
                    : Image.file(
                        viewModel.imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
