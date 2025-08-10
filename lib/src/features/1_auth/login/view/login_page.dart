// file: lib/features/auth/view/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_view_model.dart';
import '../../../../app/utils/app_snackbar_util.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Fungsi untuk menangani hasil dari proses login
  void _handleLoginResult(BuildContext context, String? result) {
    if (context.mounted) {
      if (result == null) {
        // --- PERUBAHAN DI SINI ---
        // Tampilkan snackbar sukses sebelum navigasi
        showAppSnackbar(context: context, message: 'Login berhasil!');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Gagal, panggil SnackBar kustom kita
        showAppSnackbar(context: context, message: result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sediakan ViewModel ke widget tree
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          return Scaffold(
            backgroundColor: const Color(0xFFF7F5F2),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: keyboardHeight > 0
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: <Widget>[
                    // ... (Bagian Header Teks 'MASUK')
                    const SizedBox(height: 32),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'MASUK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan masuk dengan akun yang sudah terdaftar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 100,
                      child: Image.asset(
                        'assets/images/sipeja_logo_vertical.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 64),

                    // --- Email TextField ---
                    _buildTextField(
                      label: 'Email',
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // --- Password TextField ---
                    _buildTextField(
                      label: 'Kata Sandi',
                      controller: viewModel.passwordController,
                      obscureText: !viewModel.isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: viewModel.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Lupa Kata Sandi ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/forgot-password',
                          ),
                          child: const Text(
                            'Lupa kata sandi?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFFF68A1E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 144),

                    // --- Tombol Masuk ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final result = await viewModel.login();
                                _handleLoginResult(context, result);
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Link ke Halaman Daftar ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Memiliki akun? ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/register',
                          ),
                          child: const Text(
                            'Silahkan Daftar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFFF68A1E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  // Helper widget untuk membangun TextField agar tidak duplikasi kode
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 12),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
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
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
