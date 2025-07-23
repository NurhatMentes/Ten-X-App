import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_statistics_widget.dart';
import '../widgets/mood_map_widget.dart';

/// Ruh hali takibi ana sayfası
class MoodTrackingPage extends StatefulWidget {
  /// Kullanıcı kimliği
  final String userId;
  
  /// MoodTrackingPage constructor'ı
  const MoodTrackingPage({super.key, required this.userId});
  
  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage>
    with SingleTickerProviderStateMixin {
  /// Tab controller
  late TabController _tabController;
  
  /// Seçili ruh hali emoji
  String? _selectedMoodEmoji;
  
  /// Açıklama text controller
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Tab değişikliklerini dinle
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDataForCurrentTab();
      }
    });
    
    // İlk yükleme
    _loadDataForCurrentTab();
  }
  
  /// Mevcut sekme için gerekli verileri yükle
  void _loadDataForCurrentTab() {
    // Sadece ilk yüklemede veya tab değişiminde gerekli verileri yükle
    final currentState = context.read<MoodBloc>().state;
    
    switch (_tabController.index) {
      case 0: // Bugün
        if (currentState is! TodayMoodEntryLoaded) {
          context.read<MoodBloc>().add(
            GetTodayMoodEntryEvent(userId: widget.userId),
          );
        }
        break;
      case 1: // Geçmiş
      case 2: // İstatistikler
      case 3: // Harita
        if (currentState is! UserMoodEntriesLoaded) {
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
        }
        break;
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh Hali Takibi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Bugün', icon: Icon(Icons.today)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history)),
            Tab(text: 'İstatistikler', icon: Icon(Icons.analytics)),
            Tab(text: 'Harita', icon: Icon(Icons.map)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildHistoryTab(),
          _buildStatsTab(),
          _buildMapTab(),
        ],
      ),
    );
  }
  
  /// Harita sekmesi
  Widget _buildMapTab() {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        // Sadece veri yüklenmemişse yükle
        if (state is! UserMoodEntriesLoaded && state is! MoodLoading) {
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
        }
        
        return MoodMapWidget(userId: widget.userId);
      },
    );
  }
  
  /// Bugün sekmesi
  Widget _buildTodayTab() {
    return BlocConsumer<MoodBloc, MoodState>(
      listener: (context, state) {
        if (state is MoodEntryAdded || state is MoodEntryUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ruh haliniz kaydedildi!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          
          // Verileri yenile
          context.read<MoodBloc>().add(
            GetTodayMoodEntryEvent(userId: widget.userId),
          );
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
        } else if (state is MoodError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bugünün tarihi
              Text(
                'Bugün - ${AppDateUtils.formatDate(DateTime.now())}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Bugünkü ruh hali durumu
              if (state is TodayMoodEntryLoaded && state.moodEntry != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              state.moodEntry!.moodEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bugünkü Ruh Haliniz',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    AppDateUtils.formatTime(state.moodEntry!.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showMoodSelector(state.moodEntry),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                        if (state.moodEntry!.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            state.moodEntry!.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mood,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün nasıl hissediyorsunuz?',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showMoodSelector(null),
                          child: const Text('Ruh Halimi Kaydet'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Ruh hali seçenekleri
              Text(
                'Ruh Hali Seçenekleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              MoodSelector(
                selectedMood: _selectedMoodEmoji,
                onMoodSelected: (emoji) {
                  setState(() {
                    _selectedMoodEmoji = emoji;
                  });
                  _showMoodSelector(null);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Geçmiş sekmesi
  Widget _buildHistoryTab() {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        // Önce kullanıcının mood entries'lerini yükle
        if (state is! UserMoodEntriesLoaded && state is! MoodLoading) {
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
        }
        
        if (state is UserMoodEntriesLoaded) {
          if (state.moodEntries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz ruh hali kaydınız yok',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.moodEntries.length,
            itemBuilder: (context, index) {
              final moodEntry = state.moodEntries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(moodEntry.moodEmoji, style: const TextStyle(fontSize: 24)),
                  title: Text(AppDateUtils.formatDateTime(moodEntry.createdAt)),
                  subtitle: moodEntry.description != null ? Text(moodEntry.description!) : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showMoodSelector(moodEntry);
                      } else if (value == 'delete') {
                        _deleteMoodEntry(moodEntry.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        }
        
        if (state is MoodLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is MoodError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MoodBloc>().add(
                      GetUserMoodEntriesEvent(userId: widget.userId),
                    );
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
  /// İstatistikler sekmesi
  Widget _buildStatsTab() {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, state) {
        // Önce kullanıcının mood entries'lerini yükle
        if (state is! UserMoodEntriesLoaded && state is! MoodLoading) {
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
        }
        
        if (state is UserMoodEntriesLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Son 30 Gün İstatistikleri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                MoodStatisticsWidget(
                  moodEntries: state.moodEntries,
                  selectedTimeRange: 'Aylık',
                  onTimeRangeChanged: (timeRange) {
                    final now = DateTime.now();
                    DateTime startDate;
                    DateTime endDate = now;

                    switch (timeRange) {
                      case 'Günlük':
                        startDate = now;
                        break;
                      case 'Haftalık':
                        startDate = now.subtract(const Duration(days: 7));
                        break;
                      case 'Aylık':
                        startDate = now.subtract(const Duration(days: 30));
                        break;
                      case '3 Aylık':
                        startDate = now.subtract(const Duration(days: 90));
                        break;
                      case 'Yıllık':
                        startDate = now.subtract(const Duration(days: 365));
                        break;
                      default:
                        startDate = now.subtract(const Duration(days: 30));
                    }

                    context.read<MoodBloc>().add(
                      GetUserMoodEntriesEvent(userId: widget.userId),
                    );
                  },
                ),
              ],
            ),
          );
        }
        
        if (state is MoodLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is MoodError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
  /// Ruh hali seçici dialog'unu göster
  void _showMoodSelector(dynamic existingEntry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingEntry != null ? 'Ruh Halini Güncelle' : 'Ruh Halini Kaydet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                MoodSelector(
                  selectedMood: existingEntry?.moodEmoji ?? _selectedMoodEmoji,
                  onMoodSelected: (emoji) {
                    setState(() {
                      _selectedMoodEmoji = emoji;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    hintText: 'Bugün nasıl hissettiniz?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _descriptionController.clear();
                          setState(() {
                            _selectedMoodEmoji = null;
                          });
                        },
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedMoodEmoji != null
                            ? () => _saveMoodEntry(existingEntry)
                            : null,
                        child: Text(existingEntry != null ? 'Güncelle' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Ruh hali girişini kaydet
  void _saveMoodEntry(dynamic existingEntry) async {
    if (_selectedMoodEmoji == null) return;
    
    // Mevcut konumu al
    String? locationString;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationString = '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Konum alınamadı: $e');
      // Konum alınamazsa null bırak
    }
    
    if (existingEntry != null) {
      // Güncelleme
      context.read<MoodBloc>().add(
        UpdateMoodEntryEvent(
          id: existingEntry.id,
          userId: widget.userId,
          moodEmoji: _selectedMoodEmoji!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: existingEntry.createdAt,
          location: locationString,
        ),
      );
    } else {
      // Yeni ekleme
      context.read<MoodBloc>().add(
        AddMoodEntryEvent(
          userId: widget.userId,
          moodEmoji: _selectedMoodEmoji!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          location: locationString,
        ),
      );
    }
    
    Navigator.pop(context);
    _descriptionController.clear();
    setState(() {
      _selectedMoodEmoji = null;
    });
  }
  
  /// Ruh hali girişini sil
  void _deleteMoodEntry(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Girişi Sil'),
        content: const Text('Bu ruh hali girişini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<MoodBloc>().add(DeleteMoodEntryEvent(id: id));
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}