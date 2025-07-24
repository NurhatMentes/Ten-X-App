import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_state.dart';
import '../bloc/mood_event.dart';
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
  
  /// Emoji marker cache'i (performans için)
  final Map<String, BitmapDescriptor> _emojiMarkerCache = {};
  
  /// Son işlenen mood entries listesi (performans için)
  List<MoodEntry>? _lastProcessedEntries;
  
  /// Marker'lar oluşturuldu mu?
  bool _markersCreated = false;
  
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
  
  /// Konumu bulanıklaştırır (gizlilik için yaklaşık konum)
  /// [seed] parametresi ile aynı konum için her zaman aynı offset üretir
  LatLng _blurLocation(double lat, double lng, {int? seed}) {
    // Seed değeri verilmemişse koordinatları kullan
    final randomSeed = seed ?? (lat * 1000000 + lng * 1000000).toInt();
    
    // Sabit seed ile deterministik rastgele değerler üret
    final offsetLat = ((randomSeed % 1000) - 500) / 100000; // ~500m max offset
    final offsetLng = (((randomSeed * 7) % 1000) - 500) / 100000; // Farklı pattern için 7 ile çarp
    
    return LatLng(
      lat + offsetLat,
      lng + offsetLng,
    );
  }

  /// Emoji için özel marker icon'u oluşturur (optimize edilmiş)
  Future<BitmapDescriptor> _createEmojiMarker(String emoji) async {
    try {
      // Canvas boyutları - daha küçük boyut (performans için)
      const double size = 80;
      const double emojiSize = 40;
      
      // PictureRecorder ile canvas oluştur
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      
      // Basit arka plan çemberi (gölge kaldırıldı)
      final Paint backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final Paint borderPaint = Paint()
        ..color = Colors.blue.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2; // Daha ince çerçeve
      
      // Arka plan çemberi
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        emojiSize / 2,
        backgroundPaint,
      );
      
      // Çerçeve
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        emojiSize / 2,
        borderPaint,
      );
      
      // Emoji metni çiz - daha küçük font boyutu (performans için)
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: const TextStyle(
            fontSize: 24, // Daha küçük font
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Emoji'yi merkeze yerleştir
      final offset = Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      );
      
      textPainter.paint(canvas, offset);
      
      // Picture'ı image'e çevir
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
      
      // Image'ı byte array'e çevir
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return BitmapDescriptor.defaultMarker;
      }
      
      final Uint8List uint8List = byteData.buffer.asUint8List();
      
      return BitmapDescriptor.bytes(uint8List);
    } catch (e) {
      debugPrint('Emoji marker oluşturma hatası ($emoji): $e');
      // Hata durumunda varsayılan marker döndür
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Marker'ların güncellenmesi gerekip gerekmediğini kontrol eder
  bool _shouldUpdateMarkers(List<MoodEntry> newEntries) {
    if (_lastProcessedEntries == null) return true;
    if (_lastProcessedEntries!.length != newEntries.length) return true;
    
    // Entry ID'lerini karşılaştır
    final lastIds = _lastProcessedEntries!.map((e) => e.id).toSet();
    final newIds = newEntries.map((e) => e.id).toSet();
    
    return !lastIds.containsAll(newIds) || !newIds.containsAll(lastIds);
  }
  
  /// Harita işaretçilerini oluşturur
  Future<void> _createMarkers(List<MoodEntry> moodEntries) async {
    try {
      debugPrint('Marker\'lar oluşturuluyor... Toplam entry: ${moodEntries.length}');
      _markers.clear();
      
      // Kullanıcı konumu marker'ı kaldırıldı - sadece emoji marker'lar gösterilecek
      
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
              // Konumu bulanıklaştır (gizlilik için) - entry ID'sini seed olarak kullan
              position = _blurLocation(lat, lng, seed: entry.id.hashCode);
            } else {
              // Geçersiz konum formatı, varsayılan konum kullan
              final lat = _currentPosition?.latitude ?? 41.0082;
              final lng = _currentPosition?.longitude ?? 28.9784;
              position = _blurLocation(
                lat,
                lng,
                seed: entry.id.hashCode,
              );
            }
          } catch (e) {
            // Konum parse edilemedi, varsayılan konum kullan
            final lat = _currentPosition?.latitude ?? 41.0082;
            final lng = _currentPosition?.longitude ?? 28.9784;
            position = _blurLocation(
              lat,
              lng,
              seed: entry.id.hashCode,
            );
          }
          
          // Emoji marker oluştur veya cache'den al
          BitmapDescriptor emojiIcon;
          try {
            if (_emojiMarkerCache.containsKey(entry.moodEmoji)) {
              emojiIcon = _emojiMarkerCache[entry.moodEmoji]!;
            } else {
              emojiIcon = await _createEmojiMarker(entry.moodEmoji);
              _emojiMarkerCache[entry.moodEmoji] = emojiIcon;
            }
          } catch (e) {
            debugPrint('Emoji marker oluşturma hatası (${entry.moodEmoji}): $e');
            // Hata durumunda emoji'ye göre renk belirle (fallback)
            double hue;
            switch (entry.moodEmoji) {
              case '😀':
              case '😊':
              case '🙂':
              case '😄':
              case '😁':
                hue = BitmapDescriptor.hueGreen;
                break;
              case '😐':
              case '🤔':
              case '😑':
                hue = BitmapDescriptor.hueYellow;
                break;
              case '😔':
              case '😢':
              case '😭':
              case '😞':
              case '😟':
                hue = BitmapDescriptor.hueRed;
                break;
              case '😴':
              case '😪':
                hue = BitmapDescriptor.hueViolet;
                break;
              case '😡':
              case '😠':
                hue = BitmapDescriptor.hueOrange;
                break;
              default:
                hue = BitmapDescriptor.hueViolet;
            }
            emojiIcon = BitmapDescriptor.defaultMarkerWithHue(hue);
          }
          
          _markers.add(
            Marker(
              markerId: MarkerId(entry.id),
              position: position,
              infoWindow: InfoWindow(
                title: '${entry.moodEmoji} Ruh Hali',
                snippet: entry.description ?? 'Açıklama yok',
              ),
              icon: emojiIcon,
            ),
          );
        }
      }
      
      debugPrint('Toplam ${_markers.length} marker oluşturuldu (bulanıklaştırılmış konumlarla)');
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Marker oluşturma hatası: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<MoodBloc, MoodState>(
      listener: (context, state) {
        // Ruh hali eklendiğinde veya güncellendiğinde bugünkü verileri yenile
        if (state is MoodEntryAdded || state is MoodEntryUpdated) {
          _markersCreated = false; // Marker'ları yeniden oluşturmaya zorla
          context.read<MoodBloc>().add(
            GetMoodEntriesByDateRangeEvent(
              userId: widget.userId,
              startDate: DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
              endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
            ),
          );
        }
      },
      child: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, state) {
          // Bugünkü ruh hali verilerini yükle (sadece bir kez)
          if (state is! MoodEntriesByDateRangeLoaded && state is! MoodLoading && !_markersCreated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<MoodBloc>().add(
                  GetMoodEntriesByDateRangeEvent(
                    userId: widget.userId,
                    startDate: DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
                    endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
                  ),
                );
              }
            });
          }
          
          // Marker'ları sadece veri değiştiğinde oluştur
          if (state is MoodEntriesByDateRangeLoaded && !_markersCreated) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted && _shouldUpdateMarkers(state.moodEntries)) {
                await _createMarkers(state.moodEntries);
                _lastProcessedEntries = List.from(state.moodEntries);
                _markersCreated = true;
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
      ),
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