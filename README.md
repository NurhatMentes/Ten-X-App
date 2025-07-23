# Ten-X App - Flutter & Firebase Mobil Uygulama

## Proje Özeti
"Ten-X" adlı mobil uygulama, Flutter framework'ü ve Firebase backend servislerini kullanarak geliştirilmiş sosyal bir karar verme platformudur. Uygulama günde 10 kez açılacak kadar çekici, dopamin uyandıran ve kullanıcıların ruh halini, kararlarını takip etmelerine yardımcı olan özellikler sunar.

## 🚀 Özellikler (MVP v1.0.0)

### ✅ Tamamlanan Özellikler
- **Karar Takip Sistemi**: Decision model ile karar yönetimi
- **Modern UI**: Material Design 3 ile responsive arayüz
- **Karar Kartları**: Öncelik ve durum gösterimi ile DecisionCard bileşeni
- **Yeni Karar Ekleme**: CreateDecisionDialog ile karar oluşturma
- **Clean Architecture**: Katmanlı mimari yapısı
- **Firebase Hazırlığı**: Firebase entegrasyonu için dependency'ler

### 🔄 Geliştirme Aşamasında
- **Günlük Ruh Hali Haritası**: Emoji ile ruh hali seçimi ve şehir bazlı istatistikler
- **5 Saniyede Karar**: Fotoğraf yükleme ve topluluk oylaması
- **Mini Karar Defteri**: Karar geçmişi ve başarı oranı takibi

## 🛠️ Teknoloji Stack'i

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage, Analytics)
- **State Management**: BLoC Pattern (flutter_bloc)
- **Navigation**: GoRouter
- **UI Framework**: Material Design 3
- **Architecture**: Clean Architecture (SOLID Principles)

## 📱 Desteklenen Platformlar

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🏗️ Proje Yapısı

```
lib/
├── core/                    # Temel yapılar ve utilities
│   ├── constants/          # Uygulama sabitleri
│   ├── errors/            # Hata yönetimi
│   ├── network/           # Network katmanı
│   └── utils/             # Yardımcı fonksiyonlar
├── features/              # Özellik bazlı modüller
│   ├── mood_tracking/     # Ruh hali takibi
│   ├── decision_voting/   # Karar oylama
│   └── decision_diary/    # Karar defteri
├── shared/                # Paylaşılan bileşenler
│   ├── widgets/           # Ortak widget'lar
│   └── services/          # Ortak servisler
└── main.dart             # Uygulama giriş noktası
```

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- Git

### Kurulum Adımları

1. **Repository'yi klonlayın:**
   ```bash
   git clone https://github.com/NurhatMentes/Ten-X-App.git
   cd Ten-X-App
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   # Web için
   flutter run -d chrome --web-port=3000
   
   # Android için
   flutter run -d android
   
   # iOS için
   flutter run -d ios
   ```

## 🔧 Geliştirme

### Code Quality
- Linting kurallarına uygun kod yazımı
- SOLID prensiplere uygun mimari
- Türkçe documentation
- Unit test coverage

### Git Workflow
```bash
main          # Production ready code
develop       # Development branch
feature/*     # Yeni özellik branch'leri
hotfix/*      # Acil düzeltme branch'leri
release/*     # Release hazırlık branch'leri
```

### Versiyonlama
- **v1.0.0** - MVP Release
- **v1.1.0** - Minor feature additions
- **v1.0.1** - Bug fixes
- **v2.0.0** - Major version (breaking changes)

## 📊 Başarı Metrikleri

- Günlük aktif kullanıcı sayısı
- Kullanıcı başına günlük açılış sayısı (hedef: 10x)
- Feature adoption rate (%70+ kullanıcı tüm 3 ana özelliği kullanmalı)
- App store rating (4.0+)
- Crash-free session rate (%99+)

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Geliştirici**: Nurhat Mentes
- **Email**: nurhatmentes@gmail.com
- **GitHub**: [@NurhatMentes](https://github.com/NurhatMentes)
- **Repository**: [Ten-X-App](https://github.com/NurhatMentes/Ten-X-App)

## 🎯 Roadmap

### v1.1.0 (Gelecek Sürüm)
- Firebase Authentication entegrasyonu
- Firestore veritabanı bağlantısı
- Ruh hali takibi özelliği
- Lokasyon bazlı istatistikler

### v1.2.0
- Fotoğraf yükleme ve oylama sistemi
- Real-time voting
- Push notification'lar

### v2.0.0
- Sosyal özellikler
- Gelişmiş analitik
- Premium özellikler
- Multi-language support

---

**Ten-X App** - Kararlarınızı daha akıllıca verin! 🚀
