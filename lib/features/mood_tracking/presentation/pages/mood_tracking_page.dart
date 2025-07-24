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
  
  /// Tab bazında yükleme durumları
  final Map<int, bool> _tabDataLoaded = {
    0: false, // Bugün
    1: false, // Geçmiş
    2: false, // İstatistikler
    3: false, // Harita
  };
  
  /// Son yüklenen veri zamanları (önbellekleme için)
  final Map<int, DateTime> _lastLoadTimes = {};
  
  /// Veri önbellekleme süresi (dakika)
  static const int _cacheValidityMinutes = 5;
  
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
  
  /// Mevcut sekme için gerekli verileri yükle (optimize edilmiş)
  void _loadDataForCurrentTab() {
    final currentTab = _tabController.index;
    final currentState = context.read<MoodBloc>().state;
    
    // Önbellekleme kontrolü
    if (_isDataCacheValid(currentTab)) {
      return;
    }
    
    // Loading durumunda tekrar yükleme yapma
    if (currentState is MoodLoading) {
      return;
    }
    
    switch (currentTab) {
      case 0: // Bugün
        if (!_tabDataLoaded[0]! || 
            currentState is! TodayMoodEntryLoaded ||
            _shouldRefreshTodayData(currentState)) {
          context.read<MoodBloc>().add(
            GetTodayMoodEntryEvent(userId: widget.userId),
          );
          _tabDataLoaded[0] = true;
          _lastLoadTimes[0] = DateTime.now();
        }
        break;
      case 1: // Geçmiş
      case 2: // İstatistikler
        if (!_tabDataLoaded[currentTab]! || 
            currentState is! UserMoodEntriesLoaded) {
          context.read<MoodBloc>().add(
            GetUserMoodEntriesEvent(userId: widget.userId),
          );
          _tabDataLoaded[currentTab] = true;
          _lastLoadTimes[currentTab] = DateTime.now();
        }
        break;
      case 3: // Harita
        if (!_tabDataLoaded[3]! || 
            currentState is! MoodEntriesByDateRangeLoaded) {
          context.read<MoodBloc>().add(
            GetMoodEntriesByDateRangeEvent(
              userId: widget.userId,
              startDate: DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
              endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
            ),
          );
          _tabDataLoaded[3] = true;
          _lastLoadTimes[3] = DateTime.now();
        }
        break;
    }
  }
  
  /// Veri önbelleğinin geçerli olup olmadığını kontrol eder
  bool _isDataCacheValid(int tabIndex) {
    final lastLoadTime = _lastLoadTimes[tabIndex];
    if (lastLoadTime == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(lastLoadTime).inMinutes;
    
    return difference < _cacheValidityMinutes;
  }
  
  /// Bugün verilerinin yenilenmesi gerekip gerekmediğini kontrol eder
  bool _shouldRefreshTodayData(MoodState state) {
    if (state is TodayMoodEntryLoaded) {
      // Eğer bugünkü veri yoksa veya eski tarihli ise yenile
      if (state.moodEntry == null) return true;
      
      final entryDate = state.moodEntry!.createdAt;
      final today = DateTime.now();
      
      return !_isSameDay(entryDate, today);
    }
    return true;
  }
  
  /// İki tarihin aynı gün olup olmadığını kontrol eder
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Veri önbelleğini temizler (yeni veri eklendiğinde)
  void _clearDataCache() {
    _tabDataLoaded.updateAll((key, value) => false);
    _lastLoadTimes.clear();
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
  
  /// Harita sekmesi (optimize edilmiş)
  Widget _buildMapTab() {
    // Veri yükleme işlemi _loadDataForCurrentTab metodunda yapılıyor
    return MoodMapWidget(userId: widget.userId);
  }
  
  /// Bugün sekmesi
  Widget _buildTodayTab() {
    return BlocConsumer<MoodBloc, MoodState>(
      listenWhen: (previous, current) {
        // Sadece belirli state değişikliklerinde dinle
        return current is MoodEntryAdded || 
               current is MoodEntryUpdated ||
               current is MoodEntryDeleted ||
               current is MoodError;
      },
      buildWhen: (previous, current) {
        // Sadece bugün sekmesi ile ilgili state değişikliklerinde rebuild yap
        if (current is TodayMoodEntryLoaded) return true;
        if (current is MoodLoading && previous is! MoodLoading) return true;
        if (current is MoodError) return true;
        if (current is MoodEntryAdded || current is MoodEntryUpdated || current is MoodEntryDeleted) {
          // Sadece bugünkü tarihle ilgili değişikliklerde rebuild yap
          final today = DateTime.now();
          if (current is MoodEntryAdded) {
             return _isSameDay(current.moodEntry.createdAt, today);
           }
           if (current is MoodEntryUpdated) {
             return _isSameDay(current.moodEntry.createdAt, today);
           }
          if (current is MoodEntryDeleted) {
            return true; // Silme işleminde her zaman rebuild yap
          }
        }
        return false;
      },
      listener: (context, state) {
        if (state is MoodEntryAdded || state is MoodEntryUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ruh haliniz kaydedildi!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          
          // Veri önbelleğini temizle ve verileri yenile
          _clearDataCache();
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
              
              // Hızlı ruh hali seçenekleri
              if (state is! TodayMoodEntryLoaded || state.moodEntry == null) ...[
                Text(
                  'Hızlı Seçim',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Hızlı emoji seçenekleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickMoodButton('😊', 'Mutlu'),
                    _buildQuickMoodButton('😐', 'Nötr'),
                    _buildQuickMoodButton('😢', 'Üzgün'),
                    _buildQuickMoodButton('😡', 'Kızgın'),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Daha fazla seçenek butonu
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMoodSelector(null),
                    icon: const Icon(Icons.more_horiz),
                    label: const Text('Daha Fazla Seçenek'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  /// Geçmiş sekmesi
  Widget _buildHistoryTab() {
    return BlocBuilder<MoodBloc, MoodState>(
      buildWhen: (previous, current) {
        // Sadece geçmiş sekmesi ile ilgili state'lerde rebuild yap
        return current is UserMoodEntriesLoaded ||
               current is MoodLoading ||
               current is MoodError ||
               current is MoodEntryDeleted;
      },
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
      buildWhen: (previous, current) {
        // Sadece istatistikler sekmesi ile ilgili state'lerde rebuild yap
        return current is UserMoodEntriesLoaded ||
               current is MoodLoading ||
               current is MoodError;
      },
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
    
    // Context'i async işlemden önce sakla
    final navigator = Navigator.of(context);
    final moodBloc = context.read<MoodBloc>();
    
    // Mevcut konumu al
    String? locationString;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      locationString = '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Konum alınamadı: $e');
      // Konum alınamazsa null bırak
    }
    
    if (existingEntry != null) {
      // Güncelleme
      moodBloc.add(
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
      moodBloc.add(
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
    
    navigator.pop();
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
              final navigator = Navigator.of(context);
              final moodBloc = context.read<MoodBloc>();
              moodBloc.add(DeleteMoodEntryEvent(id: id));
              navigator.pop();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Hızlı ruh hali butonu oluştur
  Widget _buildQuickMoodButton(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodEmoji = emoji;
        });
        _showMoodSelector(null);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedMoodEmoji == emoji 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}