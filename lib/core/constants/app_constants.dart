/// Uygulama genelinde kullanılan sabit değerler
class AppConstants {
  /// Uygulama adı
  static const String appName = '10x';
  
  /// Uygulama versiyonu
  static const String appVersion = '1.0.0';
  
  /// Firebase koleksiyon isimleri
  static const String moodsCollection = 'moods';
  static const String moodEntriesCollection = 'mood_entries';
  static const String decisionsCollection = 'decisions';
  static const String votesCollection = 'votes';
  static const String usersCollection = 'users';
  static const String firestoreFriendsCollection = 'friends';
  
  /// Mood emoji değerleri
  static const List<String> moodEmojis = [
    '😊', // Mutlu
    '😐', // Nötr
    '😢', // Üzgün
    '😡', // Kızgın
    '😴', // Yorgun
    '🤔', // Düşünceli
    '😍', // Aşık
    '😎', // Havalı
  ];
  
  /// Karar kategorileri
  static const List<String> decisionCategories = [
    'Kıyafet',
    'Yemek',
    'Aktivite',
    'Alışveriş',
    'Diğer',
  ];
  
  /// Maksimum oy sayısı
  static const int maxVoteCount = 10;
  
  /// Resim yükleme limitleri
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  
  /// Animasyon süreleri (milisaniye)
  static const int shortAnimationDuration = 300;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 1000;
  
  /// Padding ve margin değerleri
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  /// Border radius değerleri
  static const double smallBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;
}