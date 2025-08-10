// lib/features/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart'; // <-- TAMBAHKAN IMPORT
import '../../../app/utils/app_snackbar_util.dart';
import '../../4_profile/view/profile_page.dart';
import '../../3_report/add_report/view/add_report_page.dart';
import '../viewmodel/home_view_model.dart'; // <-- TAMBAHKAN IMPORT
import 'home_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocationPermission();
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.location.request();
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          message:
              'Izin lokasi dinonaktifkan. Aktifkan di pengaturan untuk fungsionalitas penuh.',
        );
        await openAppSettings();
      }
    }
  }

  // --- DIUBAH --- Logika navigasi diubah untuk menangani refresh
  void _onItemTapped(int index, BuildContext context) async {
    // Ambil ViewModel sebelum navigasi, jangan listen perubahan di sini
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    switch (index) {
      case 0:
        // Index 0 adalah Beranda, tidak melakukan apa-apa.
        break;
      case 1:
        // Index 1: Navigasi ke AddReportPage dan tunggu hingga kembali.
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddReportPage()),
        );
        // Setelah kembali, panggil fungsi refresh dari ViewModel.
        await viewModel.refresh();
        break;
      case 2:
        // Index 2: Navigasi ke ProfilePage dan tunggu hingga kembali.
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        // Setelah kembali, panggil fungsi refresh dari ViewModel.
        await viewModel.refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DIUBAH --- Provider untuk HomeViewModel sekarang membungkus seluruh halaman.
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5F2),
        extendBody: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F5F2),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: SizedBox(
            height: 32,
            child: Image.asset(
              'assets/images/sipeja_logo_horizontal.png',
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {
                showAppSnackbar(
                  context: context,
                  message:
                      'Fitur ini masih belum tersedia dan sedang dalam tahap pengembangan.',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Cari',
              onPressed: () {
                showAppSnackbar(
                  context: context,
                  message:
                      'Fitur ini masih belum tersedia dan sedang dalam tahap pengembangan.',
                );
              },
            ),
          ],
        ),
        // --- DIUBAH --- Body tidak lagi membuat provider sendiri.
        body: const HomeContentPage(),
        bottomNavigationBar:
            // Consumer digunakan agar `context` yang diteruskan ke _onItemTapped
            // memiliki akses ke HomeViewModel yang disediakan di atas.
            Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 32.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF292A27),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.add),
                          label: 'Lapor',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          label: 'Profil',
                        ),
                      ],
                      currentIndex: 0,
                      selectedItemColor: const Color(0xFFF68A1E),
                      unselectedItemColor: const Color(0xFFE6E6E1),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      iconSize: 36,
                      selectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      // Panggil fungsi _onItemTapped dengan context yang benar
                      onTap: (index) => _onItemTapped(index, context),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
