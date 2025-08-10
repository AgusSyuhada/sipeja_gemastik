import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialCenter;

  const MapPickerDialog({super.key, required this.initialCenter});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final MapController _mapController = MapController();
  StreamSubscription<MapEvent>?
  _mapEventSubscription; // Untuk memegang subscription
  LatLng? _currentCenter;
  String _address = 'Geser peta untuk memilih lokasi...';
  Timer? _debounce;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialCenter;
    _getAddressFromCoordinates(widget.initialCenter);

    // Listener untuk stream event dari map controller
    // Dibungkus agar dijalankan setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapEventSubscription = _mapController.mapEventStream.listen(
          _onMapEvent,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapEventSubscription
        ?.cancel(); // Batalkan subscription saat widget di-dispose
    _mapController.dispose();
    super.dispose();
  }

  // Fungsi yang akan dipanggil setiap ada event pergerakan peta
  void _onMapEvent(MapEvent event) {
    // Kita hanya proses jika event adalah pergerakan (pan, zoom, rotate)
    if (event is MapEventMove || event is MapEventRotateEnd) {
      setState(() {
        _currentCenter = event.camera.center; // Ambil posisi tengah dari kamera
        _address = 'Memuat alamat...';
        _isLoadingAddress = true;
      });

      // Debounce untuk mencegah pemanggilan API berlebihan saat peta digeser
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        if (_currentCenter != null) {
          _getAddressFromCoordinates(_currentCenter!);
        }
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (mounted && placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
        ];
        _address = addressParts
            .where((part) => part != null && part.isNotEmpty)
            .join(', ');
        if (_address.isEmpty) _address = 'Alamat tidak ditemukan.';
      } else {
        _address = 'Alamat tidak ditemukan.';
      }
    } catch (e) {
      _address = 'Gagal mendapatkan alamat.';
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
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
            title: const Text(
              'Pilih Lokasi di Peta',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, size: 24.0),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.initialCenter,
                  initialZoom: 17.0,
                  // onPositionChanged dihapus dan diganti dengan mapEventStream
                  maxZoom: 18.4,
                  minZoom: 5.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                ],
              ),
              // Pin penanda lokasi di tengah layar
              Positioned(
                top: (MediaQuery.of(context).size.height / 4) - 50,
                child: const Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    ElevatedButton.icon(
                      onPressed: _isLoadingAddress
                          ? null
                          : () {
                              if (_currentCenter != null) {
                                Navigator.of(context).pop(_currentCenter);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF68A1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Pilih Lokasi Ini'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
