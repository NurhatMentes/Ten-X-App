import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_state.dart';
import '../../../../core/constants/app_theme.dart';

/// Ruh hali haritası widget'ı
class MoodMapWidget extends StatefulWidget {
  /// Kullanıcı kimliği
  final String userId;
  
  /// MoodMapWidget constructor'ı
  const MoodMapWidget({super.key, required this.userId});
  
  @override
  State<MoodMapWidget> createState() => _MoodMapWidgetState();
}

class _MoodMapWidgetState extends State<MoodMapWidget> {
  /// Google Maps controller'ı
  GoogleMapController? _mapController;
  
  /// Harita işaretçileri
  final Set<Marker> _markers = {};
  
  /// Kullanıcının konumu
  Position? _currentPosition;
  
  /// Harita başlangıç konumu
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784), // İstanbul koordinatları
    zoom: 11,
  );
  
  @override
  void initState() {
    super.initState();
    debugPrint('=== MoodMapWidget initState başladı ===');
    debugPrint('Widget mounted durumu: $mounted');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    debugPrint('=== MoodMapWidget initState tamamlandı ===');
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
  
  /// Emülatörün varsayılan konumunu kontrol eder
  bool _isEmulatorDefaultLocation(double latitude, double longitude) {
    // San Francisco bölgesi koordinatları (emülatör varsayılan konumu)
    const double sfLatMin = 37.0;
    const double sfLatMax = 38.0;
    const double sfLngMin = -123.0;
    const double sfLngMax = -121.0;
    
    return latitude >= sfLatMin && 
           latitude <= sfLatMax && 
           longitude >= sfLngMin && 
           longitude <= sfLngMax;
  }
  
  /// Kullanıcının mevcut konumunu alır
  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('Konum izinleri kontrol ediliyor...');
      
      // Konum servisinin aktif olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Konum servisi kapalı - Ayarları açmaya yönlendiriliyor');
        // Kullanıcıyı konum ayarlarına yönlendir
        await Geolocator.openLocationSettings();
        return;
      }
      
      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Mevcut izin durumu: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('İzin istendi, yeni durum: $permission');
        if (permission == LocationPermission.denied) {
          debugPrint('Konum izinleri reddedildi');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Konum izinleri kalıcı olarak reddedildi - Ayarlara yönlendiriliyor');
        await Geolocator.openAppSettings();
        return;
      }
      
      debugPrint('Konum alınıyor...');
      
      // Önce son bilinen konumu dene
      Position? lastKnownPosition;
      try {
        lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          debugPrint('Son bilinen konum: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
          if (mounted) {
            setState(() {
              _currentPosition = lastKnownPosition;
            });
          }
        }
      } catch (e) {
        debugPrint('Son bilinen konum alınamadı: $e');
      }
      
      // Şimdi güncel konumu al
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      
      debugPrint('Güncel konum alındı: ${position.latitude}, ${position.longitude}');
      debugPrint('Konum doğruluğu: ${position.accuracy} metre');
      
      // Emülatörün varsayılan San Francisco konumunu kontrol et ve Türkiye koordinatlarına yönlendir
      Position finalPosition = position;
      if (_isEmulatorDefaultLocation(position.latitude, position.longitude)) {
        debugPrint('Emülatör varsayılan konumu algılandı, Türkiye koordinatları kullanılıyor');
        finalPosition = Position(
          latitude: 41.0082, // İstanbul koordinatları
          longitude: 28.9784,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          altitudeAccuracy: position.altitudeAccuracy,
          headingAccuracy: position.headingAccuracy,
        );
        debugPrint('Türkiye konumu kullanılıyor: ${finalPosition.latitude}, ${finalPosition.longitude}');
      }
      
      if (mounted) {
        setState(() {
          _currentPosition = finalPosition;
        });
        
        // Haritayı kullanıcının konumuna taşı
        if (_mapController != null && _currentPosition != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15.0,
              ),
            ),
          );
          debugPrint('Harita kullanıcı konumuna taşındı');
        }
      }
    } catch (e) {
      debugPrint('Konum alınamadı: $e');
      // Hata durumunda varsayılan konumu kullan (Türkiye geneli)
      if (mounted) {
        setState(() {
          _currentPosition = Position(
            latitude: 39.9334, // Ankara koordinatları (Türkiye merkezi)
            longitude: 32.8597,
            timestamp: DateTime.now(),
            accuracy: 1000, // 1km doğruluk
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
        debugPrint('Varsayılan konum (Ankara) kullanılıyor');
      }
    }
  }
  
  /// Harita işaretçilerini oluşturur
  void _createMarkers(List<MoodEntry> moodEntries) {
    try {
      debugPrint('Marker\'lar oluşturuluyor... Toplam entry: ${moodEntries.length}');
      _markers.clear();
      
      // Kullanıcının kendi konumunu ekle
      if (_currentPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'Konumunuz'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
        debugPrint('Kullanıcı konumu marker\'ı eklendi');
      }
      
      // Ruh hali girişlerini işaretçi olarak ekle
      for (final entry in moodEntries) {
        // Konum bilgisi varsa işaretçi ekle
        if (entry.location != null) {
          // Konum bilgisini parse et
          LatLng position;
          try {
            // Konum bilgisi "lat,lng" formatında saklanmış olmalı
            final locationParts = entry.location!.split(',');
            if (locationParts.length == 2) {
              final lat = double.parse(locationParts[0]);
              final lng = double.parse(locationParts[1]);
              position = LatLng(lat, lng);
            } else {
              // Geçersiz konum formatı, varsayılan konum kullan
              final random = DateTime.now().millisecondsSinceEpoch % 100;
              final lat = _currentPosition?.latitude ?? 41.0082;
              final lng = _currentPosition?.longitude ?? 28.9784;
              position = LatLng(
                lat + (random - 50) / 1000,
                lng + (random - 50) / 1000,
              );
            }
          } catch (e) {
            // Konum parse edilemedi, varsayılan konum kullan
            final random = DateTime.now().millisecondsSinceEpoch % 100;
            final lat = _currentPosition?.latitude ?? 41.0082;
            final lng = _currentPosition?.longitude ?? 28.9784;
            position = LatLng(
              lat + (random - 50) / 1000,
              lng + (random - 50) / 1000,
            );
          }
          
          // Emoji'ye göre renk belirle
          double hue;
          switch (entry.moodEmoji) {
            case '😀':
            case '😊':
            case '🙂':
              hue = BitmapDescriptor.hueGreen;
              break;
            case '😐':
            case '🤔':
              hue = BitmapDescriptor.hueYellow;
              break;
            case '😔':
            case '😢':
            case '😭':
              hue = BitmapDescriptor.hueRed;
              break;
            default:
              hue = BitmapDescriptor.hueViolet;
          }
          
          _markers.add(
            Marker(
              markerId: MarkerId(entry.id),
              position: position,
              infoWindow: InfoWindow(
                title: entry.moodEmoji,
                snippet: entry.description ?? 'Açıklama yok',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            ),
          );
        }
      }
      
      debugPrint('Toplam ${_markers.length} marker oluşturuldu');
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Marker oluşturma hatası: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        // Sadece UserMoodEntriesLoaded state'inde marker'ları güncelle
        if (state is UserMoodEntriesLoaded && _markers.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _createMarkers(state.moodEntries);
            }
          });
        }
        
        return Column(
          children: [
            // Bölgesel ruh hali istatistikleri
            _buildMoodStats(context, state),
            
            // Harita
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildGoogleMap(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Google Map widget'ını oluşturur
  Widget _buildGoogleMap() {
    try {
      return GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        markers: Set<Marker>.from(_markers),
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: false,
        onMapCreated: _onMapCreated,
      );
    } catch (e) {
      debugPrint('GoogleMap widget oluşturma hatası: $e');
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Harita yüklenemedi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Google Maps API yapılandırmasını kontrol edin',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
  
  /// Harita oluşturulduğunda çağrılan callback
  Future<void> _onMapCreated(GoogleMapController controller) async {
    try {
      debugPrint('Harita oluşturuldu');
      
      if (!mounted) return;
      
      setState(() {
        _mapController = controller;
      });
      
      // Harita oluşturulduktan sonra mevcut konuma git
      if (_currentPosition != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted && _mapController != null) {
          try {
            await _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 15.0,
                ),
              ),
            );
            debugPrint('Kamera konumu güncellendi');
          } catch (e) {
            debugPrint('Kamera animasyon hatası: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Harita oluşturma hatası: $e');
    }
  }
  
  /// Bölgesel ruh hali istatistiklerini gösteren widget
  Widget _buildMoodStats(BuildContext context, MoodState state) {
    // Örnek istatistik verileri
    String cityName = 'İstanbul';
    int happyPercentage = 63;
    
    // Gerçek uygulamada, bu veriler Firestore'dan alınmalıdır
    if (state is UserMoodStatsLoaded) {
      // Burada gerçek istatistikleri kullanabiliriz
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(
            Icons.location_city,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Bugün $cityName ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '%$happyPercentage mutlu',
                    style: TextStyle(
                      color: happyPercentage > 50
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.mood,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}