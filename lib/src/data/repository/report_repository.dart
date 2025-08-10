import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/services/shared_preferences.dart';
import '../../app/config/app_config.dart';
import '../model/report_model.dart';

class ReportRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: AppConfig.databaseURL,
  ).ref();

  Future<void> addReport({
    required String kota,
    required String kecamatan,
    required String kelurahan,
    required String jalan,
    required String koordinat,
    required String roadImageUrl,
    required String dampak,
    required String deskripsi,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Pengguna tidak terautentikasi.");
      }

      // Membuat ID unik untuk laporan baru
      final newReportRef = _dbRef.child('reports').push();
      final String reportId = newReportRef.key!;

      final cachedUserData = await LocalCacheService.getUserData();

      // Memisahkan latitude dan longitude dari string koordinat
      final latLngParts = koordinat.split(',');
      final double latitude = double.parse(latLngParts[0].trim());
      final double longitude = double.parse(latLngParts[1].trim());

      final now = DateTime.now().toUtc().toIso8601String();

      final reporterName = cachedUserData?['name'] ?? 'Nama Tidak Ditemukan';
      final reporterProfileUrl =
          cachedUserData?['avatarUrl'] ??
          'https://placehold.co/150x150.png?text=??';

      final Map<String, dynamic> reportData = {
        'reporterInfo': {
          'userId': currentUser.uid,
          'name': reporterName,
          'profileUrl': reporterProfileUrl,
        },
        'address1': jalan,
        'address2': {
          'village_subdistrict': kelurahan,
          'district': kecamatan,
          'city_regency': kota,
        },
        'description': deskripsi,
        'impact': dampak, // Menambahkan field dampak
        'latitude': latitude,
        'longitude': longitude,
        'roadImageUrl': roadImageUrl,
        'status': 1, // Status awal: 1 = Dikirim
        'aiPrediction': 0, // Prediksi awal: 0 = Belum diproses
        'createdAt': now,
        'updatedAt': now,
      };

      await newReportRef.set(reportData);
    } catch (e) {
      print("Error adding report: $e");
      // Melempar kembali error agar bisa ditangkap oleh ViewModel
      rethrow;
    }
  }

  Future<List<Report>> fetchReports() async {
    try {
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      final snapshot = await _dbRef.child('reports').get();
      if (!snapshot.exists || snapshot.value == null) return [];

      final reportsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Report> reports = [];

      for (var entry in reportsMap.entries) {
        final reportId = entry.key;
        final reportData = Map<String, dynamic>.from(entry.value);

        final int status = (reportData['status'] as num?)?.toInt() ?? 0;

        if (status == 0) {
          continue;
        }

        final int aiPrediction =
            (reportData['aiPrediction'] as num?)?.toInt() ?? 0;

        final votesSnapshot = await _dbRef
            .child('report_upvotes')
            .child(reportId)
            .get();
        final int actualUpvotes = votesSnapshot.exists
            ? votesSnapshot.children.length
            : 0;
        final bool hasVoted =
            votesSnapshot.exists && votesSnapshot.hasChild(currentUserId);

        reports.add(
          Report(
            id: reportId,
            upvotes: actualUpvotes,
            hasVoted: hasVoted,
            reporterInfo: ReporterInfo(
              userId: reportData['reporterInfo']['userId'],
              name: reportData['reporterInfo']['name'],
              profileUrl: reportData['reporterInfo']['profileUrl'],
            ),
            address1: reportData['address1'],
            address2: AddressInfo(
              villageSubdistrict: reportData['address2']['village_subdistrict'],
              district: reportData['address2']['district'],
              cityRegency: reportData['address2']['city_regency'],
            ),
            roadImageUrl: reportData['roadImageUrl'],
            status: status,
            description: reportData['description'],
            latitude: (reportData['latitude'] as num?)?.toDouble(),
            longitude: (reportData['longitude'] as num?)?.toDouble(),
            createdAt: DateTime.parse(reportData['createdAt']),
            updatedAt: DateTime.parse(reportData['updatedAt']),
            aiPrediction: aiPrediction,
          ),
        );
      }
      return reports;
    } catch (e) {
      print("Error fetching reports with accurate vote status: $e");
      rethrow;
    }
  }

  Future<void> toggleUpvote(Report report, String userId) async {
    final bool isCurrentlyVoted = !report.hasVoted;
    final Map<String, dynamic> updates = {};

    if (isCurrentlyVoted) {
      updates['/report_upvotes/${report.id}/$userId'] = null;
    } else {
      updates['/report_upvotes/${report.id}/$userId'] = true;
    }

    return _dbRef.update(updates);
  }
}
