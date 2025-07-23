import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/usecases/add_mood_entry.dart';
import 'mood_event.dart';
import 'mood_state.dart';

/// Mood tracking için BLoC sınıfı
class MoodBloc extends Bloc<MoodEvent, MoodState> {
  /// Mood repository
  final MoodRepository moodRepository;
  
  /// Add mood entry use case
  final AddMoodEntry addMoodEntry;
  
  /// MoodBloc constructor'ı
  MoodBloc({
    required this.moodRepository,
    required this.addMoodEntry,
  }) : super(MoodInitial()) {
    on<AddMoodEntryEvent>(_onAddMoodEntry);
    on<UpdateMoodEntryEvent>(_onUpdateMoodEntry);
    on<DeleteMoodEntryEvent>(_onDeleteMoodEntry);
    on<GetMoodEntryEvent>(_onGetMoodEntry);
    on<GetUserMoodEntriesEvent>(_onGetUserMoodEntries);
    on<GetMoodEntriesByDateRangeEvent>(_onGetMoodEntriesByDateRange);
    on<GetMoodEntriesByEmojiEvent>(_onGetMoodEntriesByEmoji);
    on<GetTodayMoodEntryEvent>(_onGetTodayMoodEntry);
    on<GetUserMoodStatsEvent>(_onGetUserMoodStats);
  }
  
  /// Ruh hali girişi ekleme event handler'ı
  Future<void> _onAddMoodEntry(
    AddMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final params = AddMoodEntryParams(
      userId: event.userId,
      moodEmoji: event.moodEmoji,
      description: event.description,
      location: event.location,
      weather: event.weather,
      activity: event.activity,
      tags: event.tags,
    );
    
    final result = await addMoodEntry(params);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntry) => emit(MoodEntryAdded(moodEntry: moodEntry)),
    );
  }
  
  /// Ruh hali girişi güncelleme event handler'ı
  Future<void> _onUpdateMoodEntry(
    UpdateMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final moodEntry = MoodEntry(
      id: event.id,
      userId: event.userId,
      moodEmoji: event.moodEmoji,
      description: event.description,
      createdAt: event.createdAt,
      updatedAt: DateTime.now(),
      location: event.location,
      weather: event.weather,
      activity: event.activity,
      tags: event.tags,
    );
    
    final result = await moodRepository.updateMoodEntry(moodEntry);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (updatedMoodEntry) => emit(MoodEntryUpdated(moodEntry: updatedMoodEntry)),
    );
  }
  
  /// Ruh hali girişi silme event handler'ı
  Future<void> _onDeleteMoodEntry(
    DeleteMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.deleteMoodEntry(event.id);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (success) => emit(MoodEntryDeleted(id: event.id)),
    );
  }
  
  /// Belirli bir ruh hali girişini getirme event handler'ı
  Future<void> _onGetMoodEntry(
    GetMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getMoodEntry(event.id);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntry) => emit(MoodEntryLoaded(moodEntry: moodEntry)),
    );
  }
  
  /// Kullanıcının tüm ruh hali girişlerini getirme event handler'ı
  Future<void> _onGetUserMoodEntries(
    GetUserMoodEntriesEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getUserMoodEntries(event.userId);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntries) => emit(UserMoodEntriesLoaded(moodEntries: moodEntries)),
    );
  }
  
  /// Belirli bir tarih aralığındaki ruh hali girişlerini getirme event handler'ı
  Future<void> _onGetMoodEntriesByDateRange(
    GetMoodEntriesByDateRangeEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getMoodEntriesByDateRange(
      event.userId,
      event.startDate,
      event.endDate,
    );
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntries) => emit(MoodEntriesByDateRangeLoaded(
        moodEntries: moodEntries,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }
  
  /// Belirli bir ruh hali emoji'sine göre girişleri getirme event handler'ı
  Future<void> _onGetMoodEntriesByEmoji(
    GetMoodEntriesByEmojiEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getMoodEntriesByEmoji(
      event.userId,
      event.moodEmoji,
    );
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntries) => emit(MoodEntriesByEmojiLoaded(
        moodEntries: moodEntries,
        moodEmoji: event.moodEmoji,
      )),
    );
  }
  
  /// Kullanıcının bugünkü ruh hali girişini getirme event handler'ı
  Future<void> _onGetTodayMoodEntry(
    GetTodayMoodEntryEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getTodayMoodEntry(event.userId);
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (moodEntry) => emit(TodayMoodEntryLoaded(moodEntry: moodEntry)),
    );
  }
  
  /// Kullanıcının ruh hali istatistiklerini getirme event handler'ı
  Future<void> _onGetUserMoodStats(
    GetUserMoodStatsEvent event,
    Emitter<MoodState> emit,
  ) async {
    emit(MoodLoading());
    
    final result = await moodRepository.getUserMoodStats(
      event.userId,
      event.startDate,
      event.endDate,
    );
    
    result.fold(
      (failure) => emit(MoodError(message: failure.message)),
      (stats) => emit(UserMoodStatsLoaded(
        stats: stats,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }
}