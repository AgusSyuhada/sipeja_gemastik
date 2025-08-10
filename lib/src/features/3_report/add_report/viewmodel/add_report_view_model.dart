import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../../../data/model/address_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/repository/report_repository.dart';
import '../../../../app/config/app_config.dart';

class AddReportViewModel with ChangeNotifier {
  final _reportRepository = ReportRepository();

  final jalanController = TextEditingController();
  final koordinatController = TextEditingController();
  final dampakController = TextEditingController();
  final deskripsiController = TextEditingController();
  File? _imageFile;

  final String kota = AddressData.kota;
  final List<String> _kecamatanList = AddressData.kecamatanList;
  final Map<String, List<String>> _kelurahanMap = AddressData.kelurahanMap;

  String? _selectedKecamatan;
  String? _selectedKelurahan;
  bool _isLoadingLocation = false;
  String? _errorMessage;
  String? _infoMessage;
  bool _isSubmitting = false;

  File? get imageFile => _imageFile;
  List<String> get kecamatanList => _kecamatanList;
  List<String> getKelurahanForKecamatan(String? kecamatan) =>
      _kelurahanMap[kecamatan] ?? [];
  String? get selectedKecamatan => _selectedKecamatan;
  String? get selectedKelurahan => _selectedKelurahan;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  bool get isSubmitting => _isSubmitting;

  Future<String?> _uploadImageToFreeImageHost(File imageFile) async {
    final uri = Uri.parse(AppConfig.freeImageHostApiUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['key'] = AppConfig.freeImageHostApiKey;
    request.fields['action'] = 'upload';

    request.files.add(
      await http.MultipartFile.fromPath('source', imageFile.path),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status_code'] == 200) {
        return jsonResponse['image']['url'];
      } else {
        final errorMsg =
            jsonResponse['error']?['message'] ?? 'Unknown API error';
        print(
          "FreeImage.host Upload Error: ${response.statusCode} - $errorMsg",
        );
        throw Exception('Gagal mengunggah gambar: $errorMsg');
      }
    } catch (e) {
      print("Error during image upload: $e");
      rethrow;
    }
  }

  Future<void> submitReport() async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_imageFile == null ||
          _selectedKecamatan == null ||
          _selectedKelurahan == null ||
          jalanController.text.trim().isEmpty ||
          koordinatController.text.trim().isEmpty ||
          dampakController.text.trim().isEmpty ||
          deskripsiController.text.trim().isEmpty) {
        throw Exception("Data belum lengkap. Mohon periksa kembali.");
      }

      final imageUrl = await _uploadImageToFreeImageHost(_imageFile!);
      if (imageUrl == null) {
        throw Exception("Gagal mendapatkan URL gambar setelah diunggah.");
      }

      await _reportRepository.addReport(
        kota: kota,
        kecamatan: _selectedKecamatan!,
        kelurahan: _selectedKelurahan!,
        jalan: jalanController.text.trim(),
        koordinat: koordinatController.text.trim(),
        roadImageUrl: imageUrl,
        dampak: dampakController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      print("Gagal mengambil gambar: $e");
      _errorMessage = "Gagal mengambil gambar: $e";
      notifyListeners();
    }
  }

  void updateKecamatan(String? newValue) {
    if (newValue != _selectedKecamatan) {
      _selectedKecamatan = newValue;
      _selectedKelurahan = null;
      notifyListeners();
    }
  }

  void updateKelurahan(String? newValue) {
    _selectedKelurahan = newValue;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
  }

  // --- FIX: Logika pemrosesan alamat dirombak total ---
  (String?, String?) _processPlacemark(Placemark placemark) {
    // --- KODE LOGGING UNTUK DEBUGGING ---
    print('--- Geocoding Data Received ---');
    print('Name: ${placemark.name}');
    print('Street: ${placemark.street}');
    print('Thoroughfare (Jalan Utama): ${placemark.thoroughfare}');
    print('Sub-Thoroughfare (No. Rumah): ${placemark.subThoroughfare}');
    print('Locality (Kecamatan): ${placemark.locality}');
    print('Sub-Locality (Kelurahan): ${placemark.subLocality}');
    print('Administrative Area (Provinsi): ${placemark.administrativeArea}');
    print(
      'Sub-Administrative Area (Kota/Kab): ${placemark.subAdministrativeArea}',
    );
    print('Postal Code: ${placemark.postalCode}');
    print('---------------------------------');
    // ------------------------------------

    String baseString = placemark.street ?? placemark.thoroughfare ?? '';
    if (baseString.isEmpty || baseString.contains('+')) {
      return (null, 'Alamat GPS tidak spesifik. Mohon isi manual.');
    }

    // 1. Pembersihan String Awal
    String cleanedString = baseString
        .replaceAll(RegExp(r'\s*No\.?Kelurahan\b', caseSensitive: false), '')
        .replaceAll(
          RegExp(r',\s*(No|Nomor)\.?\s*\d+\w*\b', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'\s+(No|Nomor)\.?\s*\d+\w*\b', caseSensitive: false),
          '',
        );
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      cleanedString = cleanedString.replaceAll(
        RegExp(placemark.subLocality!, caseSensitive: false),
        '',
      );
    }
    cleanedString = cleanedString
        .replaceAll(RegExp(r'\bKelurahan\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*,?\s*$'), '')
        .trim();

    // 2. Ekstraksi Bagian Gang dan Jalan
    String? gangPart;
    String? jalanPart;
    final gangRegex = RegExp(r'\b(Gg|Gang)\.?', caseSensitive: false);
    final match = gangRegex.firstMatch(cleanedString);

    if (match != null) {
      // Jika "Gang" atau "Gg" ditemukan, pisahkan string di titik itu
      int splitIndex = match.start;
      jalanPart = cleanedString.substring(0, splitIndex).trim();
      gangPart = cleanedString.substring(splitIndex).trim();
    } else {
      // Jika tidak ada gang, anggap semuanya adalah nama jalan
      jalanPart = cleanedString.trim();
    }

    // Hapus prefiks seperti "Jl." atau "Gg." dari hasil ekstraksi untuk menghindari duplikasi
    jalanPart = jalanPart?.replaceAll(RegExp(r'^(Jl|Jalan)\.?\s*'), '').trim();
    gangPart = gangPart?.replaceAll(RegExp(r'^(Gg|Gang)\.?\s*'), '').trim();

    // 3. Susun Ulang Sesuai Format: Gg. di depan, Jl. di belakang
    List<String> finalParts = [];
    if (gangPart != null && gangPart.isNotEmpty) {
      finalParts.add('Gg. $gangPart');
    }
    if (jalanPart != null && jalanPart.isNotEmpty) {
      finalParts.add('Jl. $jalanPart');
    }

    if (finalParts.isEmpty) {
      return (null, 'Nama jalan tidak dapat diproses. Mohon isi manual.');
    }

    // Validasi kasus "hanya gang"
    if ((gangPart != null && gangPart.isNotEmpty) &&
        (jalanPart == null || jalanPart.isEmpty)) {
      return (
        null,
        'Nama jalan utama tidak ditemukan, hanya gang. Mohon isi manual.',
      );
    }

    String finalRoad = finalParts.join(', ');

    return (finalRoad, null);
  }

  Future<void> getCurrentLocationAndAddress() async {
    _isLoadingLocation = true;
    clearMessages();
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak. Fitur tidak dapat digunakan.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Silakan aktifkan manual di pengaturan HP.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      koordinatController.text = '${position.latitude}, ${position.longitude}';

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final (processedStreet, message) = _processPlacemark(placemark);

        if (processedStreet != null) {
          jalanController.text = processedStreet;
        } else {
          jalanController.clear();
          _infoMessage = message;
        }

        final kecamatanFromGeocoding = placemark.locality?.toLowerCase().trim();
        final kelurahanFromGeocoding = placemark.subLocality
            ?.toLowerCase()
            .trim();

        String? foundKecamatan;
        if (kecamatanFromGeocoding != null &&
            kecamatanFromGeocoding.isNotEmpty) {
          try {
            foundKecamatan = _kecamatanList.firstWhere((kec) {
              final lowerKec = kec.toLowerCase();
              return kecamatanFromGeocoding.contains(lowerKec) ||
                  (lowerKec == 'binawidya' &&
                      kecamatanFromGeocoding.contains('tampan'));
            });
          } catch (e) {
            foundKecamatan = null;
          }
        }

        String? foundKelurahan;
        if (foundKecamatan != null) {
          final possibleKelurahan = getKelurahanForKecamatan(foundKecamatan);
          if (kelurahanFromGeocoding != null &&
              kelurahanFromGeocoding.isNotEmpty) {
            try {
              foundKelurahan = possibleKelurahan.firstWhere(
                (kel) => kelurahanFromGeocoding.contains(kel.toLowerCase()),
              );
            } catch (e) {
              foundKelurahan = null;
            }
          }
        }

        _selectedKecamatan = foundKecamatan;
        _selectedKelurahan = foundKelurahan;
      } else {
        throw Exception('Informasi alamat tidak ditemukan dari koordinat ini.');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> updateLocationFromMap(LatLng coordinates) async {
    _isLoadingLocation = true;
    clearMessages();
    notifyListeners();

    try {
      koordinatController.text =
          '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';

      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final (processedStreet, message) = _processPlacemark(placemark);

        if (processedStreet != null) {
          jalanController.text = processedStreet;
        } else {
          jalanController.clear();
          _infoMessage = message;
        }

        final kecamatanFromGeocoding = placemark.locality?.toLowerCase().trim();
        final kelurahanFromGeocoding = placemark.subLocality
            ?.toLowerCase()
            .trim();

        String? foundKecamatan;
        if (kecamatanFromGeocoding != null &&
            kecamatanFromGeocoding.isNotEmpty) {
          try {
            foundKecamatan = _kecamatanList.firstWhere((kec) {
              final lowerKec = kec.toLowerCase();
              return kecamatanFromGeocoding.contains(lowerKec) ||
                  (lowerKec == 'binawidya' &&
                      kecamatanFromGeocoding.contains('tampan'));
            });
          } catch (e) {
            foundKecamatan = null;
          }
        }

        String? foundKelurahan;
        if (foundKecamatan != null) {
          final possibleKelurahan = getKelurahanForKecamatan(foundKecamatan);
          if (kelurahanFromGeocoding != null &&
              kelurahanFromGeocoding.isNotEmpty) {
            try {
              foundKelurahan = possibleKelurahan.firstWhere(
                (kel) => kelurahanFromGeocoding.contains(kel.toLowerCase()),
              );
            } catch (e) {
              foundKelurahan = null;
            }
          }
        }

        _selectedKecamatan = foundKecamatan;
        _selectedKelurahan = foundKelurahan;
      } else {
        throw Exception('Informasi alamat tidak ditemukan dari koordinat ini.');
      }
    } catch (e) {
      _errorMessage = "Gagal memperbarui alamat dari peta: ${e.toString()}";
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    jalanController.dispose();
    koordinatController.dispose();
    dampakController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }
}
