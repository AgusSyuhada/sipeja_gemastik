import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/model/report_model.dart';
import '../../features/2_home/viewmodel/home_view_model.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onCardTap;

  const ReportCard({Key? key, required this.report, this.onCardTap})
    : super(key: key);

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
      case 1:
        return const Color(0xFF59423C);
      case 2:
        return const Color(0xFF956600);
      case 3:
        return const Color(0xFF4F6149);
      default:
        return Colors.grey.shade600;
    }
  }

  String _getAiStatus(int aiPrediction) {
    switch (aiPrediction) {
      case 1:
        return '(AI) Rusak Ringan';
      case 2:
        return '(AI) Rusak Berat';
      case 3:
        return '(AI) Bagus';
      default:
        return '(AI) Tidak Diketahui';
    }
  }

  Color _getPredictionColor(int aiPrediction) {
    switch (aiPrediction) {
      case 1:
        return const Color(0xFF956600);
      case 2:
        return const Color(0xFF950000);
      case 3:
        return const Color(0xFF259500);
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final String formattedTime = DateFormat('HH.mm').format(report.createdAt);

    return Card(
      // --- PERUBAHAN DI SINI ---
      color: const Color(
        0xFFFEFCFA,
      ), // Menambahkan warna latar belakang untuk Card
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onCardTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(
                          report.reporterInfo.profileUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.reporterInfo.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              report.address1,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${report.address2.villageSubdistrict}, ${report.address2.district}, ${report.address2.cityRegency} - $formattedTime',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getPredictionColor(report.aiPrediction),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getAiStatus(report.aiPrediction),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      report.roadImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<HomeViewModel>(
                  builder: (context, _, child) {
                    return InkWell(
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
                                fontSize: 12,
                                color: report.hasVoted
                                    ? const Color(0xFFF68A1E)
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
