// report_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/report_model.dart';
import '../../../2_home/viewmodel/home_view_model.dart';
import '../../widgets/fullscreen_map_dialog.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Diterima';
      case 2:
        return 'Diproses';
      case 3:
        return 'Selesai';
      default:
        return 'Tidak Valid';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // Diterima
        return const Color(0xFF59423C);
      case 2: // Diproses
        return const Color(0xFF956600);
      case 3: // Selesai
        return const Color(0xFF4F6149);
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(report.createdAt);

    final LatLng reportLocation = LatLng(
      report.latitude ?? 0.0,
      report.longitude ?? 0.0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // --- PERUBAHAN DIMULAI DI SINI ---
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.black.withOpacity(0.8),
                              insetPadding: const EdgeInsets.all(16.0),
                              elevation: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Image.network(
                                    report.roadImageUrl,
                                    fit: BoxFit.contain,
                                    // Menambahkan loading builder untuk user experience yang lebih baik
                                    loadingBuilder:
                                        (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            report.roadImageUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 220,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      // --- BATAS PERUBAHAN ---
                      const SizedBox(height: 24.0),
                      const Text(
                        'Detail Alamat',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${report.address1}, ${report.address2.villageSubdistrict}, ${report.address2.district}, ${report.address2.cityRegency}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Deskripsi Laporan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        report.description ?? 'Tidak ada deskripsi.',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Koordinat Lokasi',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
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
                                    userAgentPackageName: 'com.example.app',
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
                      const SizedBox(height: 24.0),
                      const Text(
                        'Pelapor',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: NetworkImage(
                              report.reporterInfo.profileUrl,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.reporterInfo.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Dilaporkan pada $formattedDate',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    // Tidak ada perubahan pada AppBar
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            splashRadius: 25,
          ),
          Expanded(
            child: Text(
              report.address1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => viewModel.toggleUpvoteOnReport(report),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            report.hasVoted
                                ? Icons.arrow_upward
                                : Icons.arrow_upward_outlined,
                            size: 20,
                            color: report.hasVoted
                                ? const Color(0xFFF68A1E)
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            NumberFormat.compact().format(report.upvotes),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: report.hasVoted
                                  ? const Color(0xFFF68A1E)
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(report.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
