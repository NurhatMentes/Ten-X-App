import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/decision_list_screen.dart';
import 'features/mood_tracking/presentation/bloc/mood_bloc.dart';
import 'features/mood_tracking/domain/usecases/add_mood_entry.dart';
import 'features/mood_tracking/data/repositories/mood_repository_impl.dart';
import 'features/mood_tracking/data/datasources/mood_remote_data_source.dart';
import 'core/network/network_info.dart';
import 'shared/services/auth_service.dart';

/// Firebase yapılandırma dosyası
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Network bilgisi sağlayıcısı
        RepositoryProvider<NetworkInfo>(
          create: (context) => NetworkInfoImpl(),
        ),
        // Auth servisi sağlayıcısı
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        // Mood remote data source sağlayıcısı
        RepositoryProvider<MoodRemoteDataSource>(
          create: (context) => MoodRemoteDataSourceImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),
        // Mood repository sağlayıcısı
        RepositoryProvider<MoodRepositoryImpl>(
          create: (context) => MoodRepositoryImpl(
            remoteDataSource: context.read<MoodRemoteDataSource>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        // Add mood entry use case sağlayıcısı
        RepositoryProvider<AddMoodEntry>(
          create: (context) => AddMoodEntry(
            context.read<MoodRepositoryImpl>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Mood BLoC sağlayıcısı
          BlocProvider<MoodBloc>(
            create: (context) => MoodBloc(
              moodRepository: context.read<MoodRepositoryImpl>(),
              addMoodEntry: context.read<AddMoodEntry>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Ten-X App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // Şimdilik DecisionListScreen'i kullanıyoruz, daha sonra bir ana sayfa oluşturacağız
          home: const DecisionListScreen(),
        ),
      ),
    );
  }
}
