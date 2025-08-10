import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/model/report_model.dart'; // Sesuaikan path import model Anda

class ReportPreviewDialog extends StatelessWidget {
  final Report report;

  const ReportPreviewDialog({Key? key, required this.report}) : super(key: key);

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
    // Menggunakan Material agar style (seperti font) sesuai dengan tema aplikasi
    return Material(
      color: Colors.transparent,
      // [PERUBAHAN] Bungkus Dialog dengan Container untuk mengatur margin
      child: Container(
        // Atur margin horizontal sesuai kebutuhan, contohnya 24.0
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Dialog(
          // [PENTING] Set insetPadding ke zero agar margin dari Container bisa bekerja
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    report.roadImageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
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
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.grey.shade700,
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          NumberFormat.compact().format(report.upvotes),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
