// file: home_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/model/report_model.dart';
import '../../../data/repository/report_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get totalReportsCount => _reports.length;

  int get processedReportsCount => _reports.where((r) => r.status == 2).length;

  int get completedReportsCount => _reports.where((r) => r.status == 3).length;

  HomeViewModel() {
    loadReports();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _reportRepository.fetchReports();
    } catch (e) {
      _errorMessage = "Gagal memuat data laporan.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadReports();
  }

  Future<void> toggleUpvoteOnReport(Report report) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (report.hasVoted) {
      report.upvotes--;
      report.hasVoted = false;
    } else {
      report.upvotes++;
      report.hasVoted = true;
    }
    notifyListeners();

    try {
      await _reportRepository.toggleUpvote(report, userId);
    } catch (e) {
      print("Gagal melakukan upvote: $e");
      if (report.hasVoted) {
        report.upvotes--;
        report.hasVoted = false;
      } else {
        report.upvotes++;
        report.hasVoted = true;
      }
      notifyListeners();
    }
  }
}
