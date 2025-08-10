// lib/features/report/view/add_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:provider/provider.dart';
import '../viewmodel/add_report_view_model.dart';
import '../../../../app/utils/app_snackbar_util.dart';
import '../../../../app/utils/app_dialog_util.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/map_picker_dialog.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import 'add_details_report_page.dart';

class AddReportPage extends StatelessWidget {
  const AddReportPage({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    // This dialog logic is now used by both the AppBar and the system back button
    return await showConfirmationDialog(
          context: context,
          icon: Icons.help_outline,
          title: 'Batalkan Laporan?',
          message:
              'Apakah Anda yakin ingin keluar? Semua data yang telah diisi akan hilang.',
          okButtonText: 'Ya, Batalkan',
          cancelButtonText: 'Tidak',
          onOkPressed: () {},
          onCancelPressed: () {},
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddReportViewModel(),
      child: WillPopScope(
        onWillPop: () => _showExitConfirmationDialog(context),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F5F2),
          // --- FIX: AppBar ditambahkan di sini ---
          appBar: AppBar(
            backgroundColor: const Color(0xFFF4F6F0),
            elevation: 0,
            scrolledUnderElevation: 0, // Mencegah perubahan warna saat scroll
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFFF4F6F0), // Samakan warna status bar
              statusBarIconBrightness: Brightness.dark, // Ikon status bar gelap
            ),
            title: GestureDetector(
              onTap: () async {
                final confirmed = await _showExitConfirmationDialog(context);
                if (confirmed) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
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
              child: Consumer<AddReportViewModel>(
                builder: (context, viewModel, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (viewModel.errorMessage != null) {
                      showAppSnackbar(
                        context: context,
                        message: "Error: ${viewModel.errorMessage!}",
                      );
                      viewModel.clearMessages();
                    }
                    if (viewModel.infoMessage != null) {
                      showAppSnackbar(
                        context: context,
                        message: viewModel.infoMessage!,
                      );
                      viewModel.clearMessages();
                    }
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // --- FIX: GestureDetector 'Kembali' dan SizedBox di bawahnya telah dipindahkan ke AppBar ---
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
                            'Lengkapi Lokasi',
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
                            'Silakan tambahkan lokasi yang ingin Anda laporkan',
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
                      _buildTextField(
                        label: 'Kota',
                        initialValue: viewModel.kota,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown(
                        label: 'Kecamatan',
                        value: viewModel.selectedKecamatan,
                        items: viewModel.kecamatanList,
                        onChanged: (value) => viewModel.updateKecamatan(value),
                        hint: 'Pilih Kecamatan',
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown(
                        label: 'Kelurahan',
                        value: viewModel.selectedKelurahan,
                        items: viewModel.getKelurahanForKecamatan(
                          viewModel.selectedKecamatan,
                        ),
                        onChanged: (value) => viewModel.updateKelurahan(value),
                        hint: 'Pilih Kelurahan',
                        disabled: viewModel.selectedKecamatan == null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Nama Jalan',
                        controller: viewModel.jalanController,
                      ),
                      const SizedBox(height: 16),
                      _buildKoordinatInput(context, viewModel),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _openMapPicker(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF68A1E,
                            ).withOpacity(0.25),
                            foregroundColor: const Color(0xFFF68A1E),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Gunakan Peta',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final missingFields = <String>[];
                            if (viewModel.selectedKecamatan == null) {
                              missingFields.add('Kecamatan');
                            }
                            if (viewModel.selectedKelurahan == null) {
                              missingFields.add('Kelurahan/Desa');
                            }
                            if (viewModel.jalanController.text.trim().isEmpty) {
                              missingFields.add('Nama Jalan');
                            }
                            if (viewModel.koordinatController.text
                                .trim()
                                .isEmpty) {
                              missingFields.add('Koordinat');
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
                              showAppSnackbar(
                                context: context,
                                message: errorMessage,
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: viewModel,
                                    child: const AddDetailsPage(),
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMapPicker(
    BuildContext context,
    AddReportViewModel viewModel,
  ) async {
    LatLng initialPoint = LatLng(0.5071, 101.4478); // Default to Pekanbaru
    if (viewModel.koordinatController.text.isNotEmpty) {
      try {
        final parts = viewModel.koordinatController.text.split(',');
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        initialPoint = LatLng(lat, lng);
      } catch (e) {
        // Ignore parsing errors, use default
      }
    }

    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialCenter: initialPoint),
    );

    if (result != null && context.mounted) {
      await viewModel.updateLocationFromMap(result);
    }
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
  }) {
    final internalController =
        controller ?? TextEditingController(text: initialValue);
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
          controller: internalController,
          enabled: enabled,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF68A1E).withOpacity(0.25),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKoordinatInput(
    BuildContext context,
    AddReportViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koordinat (Otomatis)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.koordinatController,
                enabled: false,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                decoration: InputDecoration(
                  hintText: 'Latitude, Longitude',
                  filled: true,
                  fillColor: const Color(0xFFF68A1E).withOpacity(0.25),
                  border: InputBorder.none,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: viewModel.isLoadingLocation
                    ? null
                    : viewModel.getCurrentLocationAndAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF68A1E).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: viewModel.isLoadingLocation
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
