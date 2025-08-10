import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// Sesuaikan path jika lokasi file snackbar berbeda
import '../../../app/utils/app_snackbar_util.dart';

class FullscreenMapDialog extends StatefulWidget {
  final LatLng initialCenter;

  const FullscreenMapDialog({super.key, required this.initialCenter});

  @override
  State<FullscreenMapDialog> createState() => _FullscreenMapDialogState();
}

class _FullscreenMapDialogState extends State<FullscreenMapDialog> {
  String _address = 'Mendapatkan alamat...';
  bool _isLoadingAddress = false; // Flag untuk status loading alamat

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates(widget.initialCenter);
  }

  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    setState(() {
      _address = 'Memuat alamat...';
      _isLoadingAddress = true; // Set loading aktif
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (mounted && placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ];
        _address = addressParts
            .where((part) => part != null && part.isNotEmpty)
            .join(', ');
        if (_address.isEmpty) _address = 'Alamat tidak ditemukan';
      } else {
        _address = 'Alamat tidak ditemukan';
      }
    } catch (e) {
      _address = 'Gagal mendapatkan alamat';
    } finally {
      if (mounted)
        setState(() => _isLoadingAddress = false); // Set loading selesai
    }
  }

  Future<void> _launchMaps(LatLng location) async {
    Uri uri;

    if (Platform.isAndroid) {
      uri = Uri.parse(
        'geo:0,0?q=${location.latitude},${location.longitude}(Lokasi Laporan)',
      );
    } else if (Platform.isIOS) {
      uri = Uri.parse(
        'http://maps.apple.com/?q=${location.latitude},${location.longitude}',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showAppSnackbar(
          context: context,
          message: 'Tidak dapat membuka aplikasi peta.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color universalBgColor = Color(0xFFF7F5F2);

    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      backgroundColor: universalBgColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Scaffold(
          backgroundColor: universalBgColor,
          appBar: AppBar(
            backgroundColor: universalBgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Detail Lokasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, size: 24.0),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // --- MULAI PERUBAHAN UTAMA DI SINI ---
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: widget.initialCenter,
                  initialZoom: 16.0,
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
                        point: widget.initialCenter,
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
              // Layout baru untuk alamat dan tombol, diposisikan di bawah
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Container untuk alamat dengan shadow
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: universalBgColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoadingAddress)
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          if (_isLoadingAddress) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tombol diubah menjadi ElevatedButton agar lebih konsisten
                    ElevatedButton.icon(
                      onPressed: () => _launchMaps(widget.initialCenter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF68A1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('Buka di Aplikasi Peta'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // --- AKHIR PERUBAHAN UTAMA ---
        ),
      ),
    );
  }
}
