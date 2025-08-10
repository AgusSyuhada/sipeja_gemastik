// file: lib/features/auth/view/register_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/register_view_model.dart';
import '../../../../app/utils/app_snackbar_util.dart';
import "../../../4_profile/view/privacy_policy_page.dart";
// app_dialog_util tidak lagi diperlukan untuk notifikasi ini
// import '../../../utils/app_dialog_util.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  // Menangani hasil dari proses registrasi
  void _handleRegisterResult(BuildContext context, String? result) {
    if (!context.mounted) return;

    if (result == null) {
      // --- PERUBAHAN DI SINI ---
      // Sukses: Ganti dialog dengan snackbar
      const successMessage =
          'Registrasi berhasil! Link verifikasi telah dikirim ke email Anda.';
      showAppSnackbar(context: context, message: successMessage);

      // Navigasi ke halaman login setelah menampilkan pesan
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      // Gagal
      showAppSnackbar(context: context, message: result);
    }
  }

  // Dummy functions untuk T&C dan Privacy Policy
  void _showTermsAndConditions(BuildContext context) {
    showAppSnackbar(
      context: context,
      message: 'Navigasi ke halaman Syarat & Ketentuan',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F5F2),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 32),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'DAFTAR',
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
                          'Silakan masukkan data untuk melakukan pendaftaran',
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
                    const SizedBox(height: 48),

                    // --- Input Fields ---
                    _buildTextField(
                      label: 'Nama',
                      controller: viewModel.nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email',
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Konfirmasi Kata Sandi',
                      controller: viewModel.confirmPasswordController,
                      obscureText: !viewModel.isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewModel.isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: viewModel.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Checkbox Persetujuan ---
                    Row(
                      children: [
                        SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Checkbox(
                            value: viewModel.agreeToTerms,
                            onChanged: (value) =>
                                viewModel.setAgreeToTerms(value ?? false),
                            activeColor: const Color(0xFFF68A1E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: 'Saya menyetujui '),
                                TextSpan(
                                  text: "Syarat & Ketentuan",
                                  style: const TextStyle(
                                    color: Color(0xFFF68A1E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        _showTermsAndConditions(context),
                                ),
                                const TextSpan(text: ' serta '),
                                TextSpan(
                                  text: "Kebijakan Privasi",
                                  style: const TextStyle(
                                    color: Color(0xFFF68A1E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showPrivacyPolicy(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- Tombol Daftar ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final result = await viewModel.register();
                                _handleRegisterResult(context, result);
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
                                'Daftar',
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

                    // --- Link ke Halaman Login ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah memiliki akun? ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'Silakan Masuk',
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget untuk membangun TextField
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
