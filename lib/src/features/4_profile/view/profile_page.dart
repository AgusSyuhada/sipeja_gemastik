// file: lib/features/main/view/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_view_model.dart';
import '../../../app/utils/app_dialog_util.dart';
import '../../../app/utils/app_snackbar_util.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context, ProfileViewModel viewModel) {
    showConfirmationDialog(
      context: context,
      icon: Icons.exit_to_app_outlined,
      iconColor: Colors.red,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun Anda?',
      okButtonText: 'Ya, Keluar',
      cancelButtonText: 'Batal',
      onOkPressed: () async {
        final result = await viewModel.logout();
        if (!context.mounted) return;

        if (result == null) {
          showAppSnackbar(context: context, message: 'Logout berhasil!');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          showAppSnackbar(context: context, message: result);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ViewModel akan otomatis memuat data saat halaman dibuat
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F5F2),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF7F5F2),
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color(0xFFF7F5F2),
                statusBarIconBrightness: Brightness.dark,
              ),
              title: GestureDetector(
                // Tombol kembali ini akan menutup halaman profil
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
            body: viewModel.isLoading
                // Tampilkan loading indicator saat data dimuat
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- BAGIAN HEADER PROFIL ---
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFE0E0E0),
                          // Gunakan backgroundImage jika URL tersedia
                          backgroundImage: viewModel.avatarUrl.isNotEmpty
                              ? NetworkImage(viewModel.avatarUrl)
                              : null,
                          // Tampilkan inisial nama jika URL tidak ada atau gagal dimuat
                          child:
                              viewModel.avatarUrl.isEmpty &&
                                  viewModel.name.isNotEmpty
                              ? Text(
                                  viewModel.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontFamily: 'Poppins',
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 32),

                        // --- NAMA DAN EMAIL DI BAWAH PROFIL DIHAPUS ---

                        // --- BAGIAN DETAIL AKUN ---
                        // --- WIDGET ID DIHAPUS ---
                        _buildProfileInfoTile(
                          icon: Icons.person_outline,
                          label: 'Nama',
                          // Ambil data nama dari ViewModel
                          value: viewModel.name,
                        ),
                        const Divider(height: 24, color: Colors.black12),
                        _buildProfileInfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          // Ambil data email dari ViewModel
                          value: viewModel.email,
                        ),
                        const Divider(height: 24, color: Colors.black12),
                        _buildProfileInfoTile(
                          icon: Icons.lock_outline,
                          label: 'Password',
                          value: '••••••••••',
                        ),
                        const SizedBox(height: 48),

                        // --- TOMBOL LOGOUT ---
                        ElevatedButton.icon(
                          icon: const Icon(Icons.exit_to_app_outlined),
                          label: const Text('Logout'),
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _handleLogout(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFFF68A1E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// Widget bantuan untuk membuat baris informasi profil
  /// --- TOMBOL EDIT (onEdit) DIHAPUS DARI PARAMETER DAN WIDGET ---
  Widget _buildProfileInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // --- ICON EDIT DIHAPUS DARI SINI ---
      ],
    );
  }
}
