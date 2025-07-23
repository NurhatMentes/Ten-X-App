import 'package:equatable/equatable.dart';

/// Uygulama genelinde kullanılan temel hata sınıfı
abstract class Failure extends Equatable {
  final String message;
  
  /// Failure constructor'ı - hata mesajını alır
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Sunucu ile ilgili hatalar
class ServerFailure extends Failure {
  /// ServerFailure constructor'ı
  const ServerFailure(super.message);
}

/// Ağ bağlantısı ile ilgili hatalar
class NetworkFailure extends Failure {
  /// NetworkFailure constructor'ı
  const NetworkFailure(super.message);
}

/// Cache ile ilgili hatalar
class CacheFailure extends Failure {
  /// CacheFailure constructor'ı
  const CacheFailure(super.message);
}

/// Firebase Authentication ile ilgili hatalar
class AuthFailure extends Failure {
  /// AuthFailure constructor'ı
  const AuthFailure(super.message);
}

/// Firebase Firestore ile ilgili hatalar
class FirestoreFailure extends Failure {
  /// FirestoreFailure constructor'ı
  const FirestoreFailure(super.message);
}

/// Firebase Storage ile ilgili hatalar
class StorageFailure extends Failure {
  /// StorageFailure constructor'ı
  const StorageFailure(super.message);
}

/// Lokasyon servisleri ile ilgili hatalar
class LocationFailure extends Failure {
  /// LocationFailure constructor'ı
  const LocationFailure(super.message);
}

/// Genel uygulama hataları
class GeneralFailure extends Failure {
  /// GeneralFailure constructor'ı
  const GeneralFailure(super.message);
}

/// Validation hataları
class ValidationFailure extends Failure {
  /// ValidationFailure constructor'ı
  const ValidationFailure(super.message);
}