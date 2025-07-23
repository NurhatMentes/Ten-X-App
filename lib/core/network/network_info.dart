/// Ağ bağlantısı durumunu kontrol etmek için abstract sınıf
abstract class NetworkInfo {
  /// İnternet bağlantısının olup olmadığını kontrol eden metod
  Future<bool> get isConnected;
}

/// NetworkInfo'nun concrete implementasyonu
class NetworkInfoImpl implements NetworkInfo {
  /// NetworkInfoImpl constructor'ı
  const NetworkInfoImpl();
  
  @override
  Future<bool> get isConnected async {
    try {
      // Basit bir network kontrolü
      // Gerçek uygulamada connectivity_plus paketi kullanılabilir
      return true; // Şimdilik her zaman true döndürüyoruz
    } catch (e) {
      return false;
    }
  }
}