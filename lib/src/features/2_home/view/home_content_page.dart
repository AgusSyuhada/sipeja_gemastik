// file: home_content_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/report_model.dart';
import '../viewmodel/home_view_model.dart';
import '../../../core/widgets/report_card.dart';
import '../../3_report/widgets/report_preview_dialog.dart';
import '../../3_report/detail_report/view/report_detail_page.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  OverlayEntry? _overlayEntry;

  void _showPreviewDialog(BuildContext context, Report report) {
    _removePreviewDialog();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removePreviewDialog,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Center(child: ReportPreviewDialog(report: report)),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removePreviewDialog() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removePreviewDialog();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavBarHeight = kBottomNavigationBarHeight + 72.0;

    // --- DIHAPUS --- ChangeNotifierProvider tidak lagi dibuat di sini.
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.reports.isEmpty) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF68A1E)),
          );
        }
        if (viewModel.errorMessage != null) {
          return Center(child: Text(viewModel.errorMessage!));
        }

        // --- DITAMBAHKAN --- Widget RefreshIndicator membungkus konten utama.
        return RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          color: const Color(0xFFF68A1E),
          backgroundColor: Colors.white,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Container(
              color: const Color(0xFFF7F5F2),
              child: ListView(
                // Fisik scroll ditambahkan agar refresh indicator selalu aktif
                // bahkan ketika konten tidak cukup panjang untuk di-scroll.
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 16.0,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusInfo(
                            icon: Icons.description_outlined,
                            label: 'Laporan\nMasuk',
                            count: viewModel.totalReportsCount.toString(),
                          ),
                          const VerticalDivider(
                            color: Colors.black26,
                            thickness: 1,
                          ),
                          _buildStatusInfo(
                            icon: Icons.report_outlined,
                            label: 'Laporan\nDiproses',
                            count: viewModel.processedReportsCount.toString(),
                          ),
                          const VerticalDivider(
                            color: Colors.black26,
                            thickness: 1,
                          ),
                          _buildStatusInfo(
                            icon: Icons.report_off_outlined,
                            label: 'Laporan\nSelesai',
                            count: viewModel.completedReportsCount.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: bottomNavBarHeight),
                    decoration: const BoxDecoration(
                      color: Color(0x40F68A1E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: viewModel.reports.length,
                      itemBuilder: (context, index) {
                        final report = viewModel.reports[index];
                        return GestureDetector(
                          onLongPressStart: (_) =>
                              _showPreviewDialog(context, report),
                          onLongPressEnd: (_) => _removePreviewDialog(),
                          onLongPressCancel: () => _removePreviewDialog(),
                          child: ReportCard(
                            report: report,
                            // --- DIUBAH --- Navigasi dibuat async untuk menunggu hasil.
                            onCardTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: viewModel,
                                    child: ReportDetailPage(report: report),
                                  ),
                                ),
                              );
                              // Setelah kembali dari detail, panggil refresh.
                              await viewModel.refresh();
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.0),
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

  Widget _buildStatusInfo({
    required String label,
    required String count,
    required IconData icon,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
