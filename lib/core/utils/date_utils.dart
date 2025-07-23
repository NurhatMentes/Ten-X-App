import 'package:intl/intl.dart';

/// Tarih ve zaman işlemleri için utility sınıfı
class AppDateUtils {
  /// Tarihi 'dd/MM/yyyy' formatında string'e çevirme metodu
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Tarihi 'HH:mm' formatında string'e çevirme metodu
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// Tarihi 'dd/MM/yyyy HH:mm' formatında string'e çevirme metodu
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  /// İki tarih arasındaki gün farkını hesaplama metodu
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  /// Tarihin bugün olup olmadığını kontrol eden metod
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Tarihin dün olup olmadığını kontrol eden metod
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  /// Relative time string döndüren metod ("2 saat önce", "dün", vb.)
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
  
  /// Günün başlangıcını (00:00:00) döndüren metod
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Günün sonunu (23:59:59) döndüren metod
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}