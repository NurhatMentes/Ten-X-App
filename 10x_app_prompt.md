# 10x Mobil Uygulama - Flutter & Firebase Development Prompt

## Proje Özeti
"10x" adlı mobil uygulamayı Flutter framework'ü ve Firebase backend servislerini kullanarak geliştirin. Bu uygulama günde 10 kez açılacak kadar çekici, dopamin uyandıran ve kullanıcıların ruh halini, kararlarını takip etmelerine yardımcı olan sosyal bir platform olacaktır.

## Teknik Gereksinimler

### Mimari Yaklaşım
- **SOLID Prensiplerini** tam olarak uygulayın
- **Katmanlı Mimari (Clean Architecture)** kullanın:
  - Presentation Layer (UI/Widgets)
  - Domain Layer (Business Logic/Use Cases)  
  - Data Layer (Repositories/Data Sources)
  - Infrastructure Layer (Firebase Services)

### Teknoloji Stack'i
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage, Analytics)
- **State Management**: Provider/Riverpod veya BLoC pattern
- **Versiyonlama**: Git ile semantic versioning (v1.0.0 format)

## MVP (Version 1.0.0) Özellikleri

### 1. Günlük Ruh Hali Haritası
**Fonksiyonellik:**
- Kullanıcı günde bir kez emoji ile ruh halini seçer
- Şehir/lokasyon bazlı toplu ruh hali istatistikleri görüntülenir
- "Bugün İstanbul %63 mutlu" tarzı görsel feedback

**Teknik Detaylar:**
- Firebase Firestore'da mood koleksiyonu
- Lokasyon tabanlı veri agregasyonu
- Real-time updates için StreamBuilder kullanımı

### 2. 5 Saniyede Karar
**Fonksiyonellik:**
- Fotoğraf yükleme (kıyafet, menü, vs.)
- Diğer kullanıcılardan Evet/Hayır oyları alma
- 10 oy sonrasında sonucu gösterme

**Teknik Detaylar:**
- Firebase Storage'da resim yükleme
- Firestore'da voting koleksiyonu
- Real-time vote counting

### 3. Anlık Pişmanlık / Mini Karar Defteri
**Fonksiyonellik:**
- Verilen kararları 1-5 arası puanlama
- Kişisel karar geçmişi ve başarı oranı takibi
- "Kararlarının %68'i seni mutlu etmiş" feedback'i

**Teknik Detaylar:**
- Kişisel decision_history koleksiyonu
- İstatistiksel hesaplamalar
- Trend analizi için grafik widgets

## Kod Yapısı ve Standartlar

### Klasör Yapısı
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── mood_tracking/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── decision_voting/
│   └── decision_diary/
├── shared/
│   ├── widgets/
│   └── services/
└── main.dart
```

### Kodlama Kuralları

#### 1. Her fonksiyon/metod için Türkçe açıklama yazın:
```dart
/// Kullanıcının günlük ruh halini Firebase'e kaydetmek için kullanılan metod
/// [mood] parametresi seçilen emoji değerini içerir
/// [location] parametresi kullanıcının şehir bilgisini içerir
/// Return: Future<bool> - işlem başarılı ise true döner
Future<bool> saveDailyMood(String mood, String location) async {
  // Implementation
}
```

#### 2. SOLID Prensipleri Uygulaması:

**Single Responsibility Principle:**
```dart
/// Sadece mood verilerini yönetmekten sorumlu repository sınıfı
class MoodRepository {
  /// Günlük mood'u veritabanına kaydetme işlemi
  Future<void> saveMood(MoodEntity mood);
  
  /// Lokasyon bazlı mood istatistiklerini getirme işlemi  
  Future<List<MoodStats>> getMoodStatsByLocation(String location);
}
```

**Open/Closed Principle:**
```dart
/// Temel veri kaynağı abstract sınıfı - genişletmeye açık, değişikliğe kapalı
abstract class DataSource {
  /// Veriyi kaydetme işlemi için abstract metod
  Future<void> save(Map<String, dynamic> data);
}

/// Firebase veri kaynağı implementasyonu
class FirebaseDataSource extends DataSource {
  /// Firebase'e veri kaydetme işleminin somut implementasyonu
  @override
  Future<void> save(Map<String, dynamic> data) async {
    // Firebase implementation
  }
}
```

**Liskov Substitution Principle:**
```dart
/// Temel repository interface'i
abstract class BaseRepository {
  /// Veri kaydetme işlemi için temel metod
  Future<Result> save(Entity entity);
}

/// Mood repository implementasyonu - BaseRepository'yi sorunsuz şekilde değiştirebilir
class MoodRepositoryImpl implements BaseRepository {
  /// Mood entity'sini kaydetme işleminin implementasyonu
  @override
  Future<Result> save(Entity entity) async {
    // Mood-specific implementation
  }
}
```

**Interface Segregation Principle:**
```dart
/// Sadece okuma işlemlerini içeren interface
abstract class ReadableRepository {
  /// Veri okuma işlemi
  Future<List<Entity>> getAll();
}

/// Sadece yazma işlemlerini içeren interface
abstract class WritableRepository {
  /// Veri yazma işlemi
  Future<void> save(Entity entity);
}
```

**Dependency Inversion Principle:**
```dart
/// Use case sınıfı, somut implementasyona değil abstraction'a bağlı
class GetMoodStatsUseCase {
  final MoodRepository _repository; // Interface'e bağlı, somut sınıfa değil
  
  /// Constructor injection ile dependency sağlama
  GetMoodStatsUseCase(this._repository);
  
  /// Mood istatistiklerini getirme işlemi
  Future<MoodStats> execute(String location) async {
    return await _repository.getMoodStatsByLocation(location);
  }
}
```

### Firebase Entegrasyonu

#### 1. Firestore Collections:
```dart
/// Mood koleksiyonu için model sınıfı
class MoodModel {
  final String id;
  final String userId;
  final String mood; // emoji string
  final String location;
  final DateTime timestamp;
  
  /// MoodModel constructor'ı - tüm gerekli parametreleri alır
  const MoodModel({
    required this.id,
    required this.userId, 
    required this.mood,
    required this.location,
    required this.timestamp,
  });
  
  /// Firestore dokümanından MoodModel oluşturma metodu
  factory MoodModel.fromFirestore(DocumentSnapshot doc) {
    // Implementation
  }
  
  /// MoodModel'i Firestore dokümanına dönüştürme metodu
  Map<String, dynamic> toFirestore() {
    // Implementation
  }
}
```

#### 2. Authentication:
```dart
/// Firebase Authentication işlemlerini yöneten servis sınıfı
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Anonim giriş yapma işlemi
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      // Hata yönetimi
      return null;
    }
  }
  
  /// Mevcut kullanıcıyı getirme işlemi
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
```

### State Management (BLoC Pattern)

```dart
/// Mood tracking için event sınıfları
abstract class MoodEvent {}

/// Mood kaydetme event'i
class SaveMoodEvent extends MoodEvent {
  final String mood;
  final String location;
  
  /// SaveMoodEvent constructor'ı
  SaveMoodEvent(this.mood, this.location);
}

/// Mood istatistiklerini getirme event'i  
class GetMoodStatsEvent extends MoodEvent {
  final String location;
  
  /// GetMoodStatsEvent constructor'ı
  GetMoodStatsEvent(this.location);
}

/// Mood tracking için state sınıfları
abstract class MoodState {}

/// Başlangıç state'i
class MoodInitialState extends MoodState {}

/// Yükleniyor state'i
class MoodLoadingState extends MoodState {}

/// Başarılı state'i
class MoodSuccessState extends MoodState {
  final MoodStats stats;
  
  /// MoodSuccessState constructor'ı
  MoodSuccessState(this.stats);
}

/// Hata state'i
class MoodErrorState extends MoodState {
  final String message;
  
  /// MoodErrorState constructor'ı
  MoodErrorState(this.message);
}

/// Mood tracking BLoC sınıfı
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository _repository;
  
  /// MoodBloc constructor'ı - repository dependency injection
  MoodBloc(this._repository) : super(MoodInitialState()) {
    on<SaveMoodEvent>(_onSaveMood);
    on<GetMoodStatsEvent>(_onGetMoodStats);
  }
  
  /// Mood kaydetme event'ini handle eden metod
  Future<void> _onSaveMood(SaveMoodEvent event, Emitter<MoodState> emit) async {
    emit(MoodLoadingState());
    try {
      await _repository.saveMood(event.mood, event.location);
      // Başarı durumunda yeni stats getir
      add(GetMoodStatsEvent(event.location));
    } catch (e) {
      emit(MoodErrorState(e.toString()));
    }
  }
  
  /// Mood istatistiklerini getirme event'ini handle eden metod
  Future<void> _onGetMoodStats(GetMoodStatsEvent event, Emitter<MoodState> emit) async {
    emit(MoodLoadingState());
    try {
      final stats = await _repository.getMoodStatsByLocation(event.location);
      emit(MoodSuccessState(stats));
    } catch (e) {
      emit(MoodErrorState(e.toString()));
    }
  }
}
```

## Versiyonlama Stratejisi

### Git Workflow:
```bash
# Ana geliştirme branch'leri
main          # Production ready code
develop       # Development branch
feature/*     # Yeni özellik branch'leri
hotfix/*      # Acil düzeltme branch'leri
release/*     # Release hazırlık branch'leri
```

### Version Format:
- **v1.0.0** - MVP Release
- **v1.1.0** - Minor feature additions
- **v1.0.1** - Bug fixes
- **v2.0.0** - Major version (breaking changes)

## UI/UX Gereksinimleri

### Ana Sayfa Layout:
```dart
/// Ana sayfa widget'ı - kullanıcının günlük etkileşimlerini yönetir
class HomePage extends StatelessWidget {
  /// HomePage constructor'ı
  const HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// Günlük mood seçimi widget'ı
          DailyMoodSelector(),
          
          /// Şehir mood istatistikleri widget'ı
          CityMoodStats(),
          
          /// Karar yükleme widget'ı
          DecisionUploader(),
          
          /// Son kararları değerlendirme widget'ı
          RecentDecisionsReview(),
        ],
      ),
    );
  }
}
```

### Theme & Design System:
```dart
/// Uygulama tema konfigürasyonu
class AppTheme {
  /// Ana renk paleti
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  
  /// Light theme konfigürasyonu
  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF6C63FF, {
      50: Color(0xFFE8E7FF),
      // ... diğer tonlar
    }),
    // Diğer theme ayarları
  );
}
```

## Testing Stratejisi

```dart
/// Mood repository için unit test sınıfı
class MoodRepositoryTest {
  late MoodRepository repository;
  late MockFirebaseFirestore mockFirestore;
  
  /// Test setup metodu - her test öncesi çalışır
  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    repository = MoodRepositoryImpl(mockFirestore);
  });
  
  /// Mood kaydetme işleminin başarılı olduğunu test eden metod
  test('should save mood successfully', () async {
    // Arrange - test verilerini hazırla
    final mood = MoodEntity(
      mood: '😊',
      location: 'Istanbul',
      timestamp: DateTime.now(),
    );
    
    // Act - test edilecek metodu çalıştır
    final result = await repository.saveMood(mood);
    
    // Assert - sonucu doğrula
    expect(result, isA<Success>());
  });
}
```

## Error Handling

```dart
/// Uygulama genelinde kullanılacak hata türleri
abstract class AppError {
  final String message;
  /// AppError constructor'ı - hata mesajını alır
  const AppError(this.message);
}

/// Network bağlantısı ile ilgili hata sınıfı
class NetworkError extends AppError {
  /// NetworkError constructor'ı
  const NetworkError(String message) : super(message);
}

/// Firebase servis hataları için hata sınıfı
class FirebaseError extends AppError {
  /// FirebaseError constructor'ı
  const FirebaseError(String message) : super(message);
}

/// Hata yönetimi için utility sınıfı
class ErrorHandler {
  /// Hata türüne göre kullanıcı dostu mesaj döndüren metod
  static String getErrorMessage(AppError error) {
    switch (error.runtimeType) {
      case NetworkError:
        return 'İnternet bağlantınızı kontrol edin';
      case FirebaseError:
        return 'Servis geçici olarak kullanılamıyor';
      default:
        return 'Beklenmeyen bir hata oluştu';
    }
  }
}
```

## Performance & Optimization

```dart
/// Lazy loading ve caching için mixin sınıfı
mixin CacheMixin {
  final Map<String, dynamic> _cache = {};
  
  /// Cache'den veri getirme metodu
  T? getCached<T>(String key) {
    return _cache[key] as T?;
  }
  
  /// Cache'e veri kaydetme metodu
  void setCached<T>(String key, T value) {
    _cache[key] = value;
  }
  
  /// Cache'i temizleme metodu
  void clearCache() {
    _cache.clear();
  }
}
```

## Delivery Requirements

### 1. Code Quality:
- Her commit'te linting kurallarına uygun kod
- %80+ test coverage
- Tüm public metodlarda Türkçe documentation
- SOLID prensiplere uygun mimari

### 2. Documentation:
- README.md dosyası (kurulum, çalıştırma, deployment)
- API documentation
- Architecture decision records (ADR)

### 3. Deployment:
- Firebase Hosting için build pipeline
- Android/iOS store release hazırlığı
- Environment-specific configuration

## Development Timeline (MVP)
- **Week 1-2**: Proje kurulumu, mimari oluşturma, Firebase konfigürasyonu
- **Week 3-4**: Mood tracking feature implementation
- **Week 5-6**: Decision voting feature implementation  
- **Week 7-8**: Decision diary feature implementation
- **Week 9-10**: UI/UX polish, testing, bug fixes
- **Week 11-12**: Performance optimization, deployment hazırlığı

## Success Metrics
- Günlük aktif kullanıcı sayısı
- Kullanıcı başına günlük açılış sayısı (hedef: 10x)
- Feature adoption rate (%70+ kullanıcı tüm 3 ana özelliği kullanmalı)
- App store rating (4.0+)
- Crash-free session rate (%99+)

Bu prompt'u takip ederek, adım adım, modern software development standartlarına uygun, ölçeklenebilir ve maintainable bir mobil uygulama geliştir..