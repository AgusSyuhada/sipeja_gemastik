// file: lib/features/auth/view/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/forgot_password_view_model.dart';
// app_dialog_util tidak lagi diperlukan untuk notifikasi ini
// import '../../../utils/app_dialog_util.dart';
import '../../../../app/utils/app_snackbar_util.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  // --- PERUBAHAN DI SINI ---
  // Menampilkan snackbar setelah email berhasil dikirim
  void _showSuccessSnackbar(BuildContext context, String email) {
    final message =
        'Link reset kata sandi telah dikirim ke $email. Silakan periksa kotak masuk Anda.';
    showAppSnackbar(context: context, message: message);
    // Langsung navigasi setelah menampilkan pesan
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Menampilkan snackbar jika terjadi error
  void _showErrorSnackbar(BuildContext context, String message) {
    showAppSnackbar(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F5F2),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // --- Tombol Kembali ---
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
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
                    const SizedBox(height: 48),

                    // --- Judul Halaman ---
                    const Text(
                      'LUPA KATA SANDI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Card Deskripsi ---
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6E1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                        'Jangan khawatir! Masukkan email yang terhubung dengan akun Anda dan kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- Input Field Email ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          style: const TextStyle(fontSize: 12),
                          controller: viewModel.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(
                              0xFFF68A1E,
                            ).withOpacity(0.25),
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- Tombol Kirim Email ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final result = await viewModel.sendResetLink();
                                if (context.mounted) {
                                  if (result == null) {
                                    // --- PERUBAHAN DI SINI ---
                                    _showSuccessSnackbar(
                                      context,
                                      viewModel.emailController.text.trim(),
                                    );
                                  } else {
                                    _showErrorSnackbar(context, result);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF68A1E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Kirim Tautan Reset',
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
      ),
    );
  }
}
