import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/mood_entry.dart';

/// Ruh hali istatistikleri widget'ı
class MoodStatisticsWidget extends StatelessWidget {
  /// Ruh hali girişleri listesi
  final List<MoodEntry> moodEntries;
  
  /// Loading durumu
  final bool isLoading;
  
  /// Seçili zaman aralığı
  final String selectedTimeRange;
  
  /// Zaman aralığı değiştiğinde çağrılacak callback
  final Function(String) onTimeRangeChanged;
  
  /// Kullanılabilir zaman aralıkları
  static const timeRanges = ['Haftalık', 'Aylık', '3 Aylık', 'Yıllık'];
  
  /// MoodStatisticsWidget constructor'ı
  const MoodStatisticsWidget({
    super.key,
    required this.moodEntries,
    required this.selectedTimeRange,
    required this.onTimeRangeChanged,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (moodEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz istatistik gösterilemiyor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İstatistikleri görmek için önce\nruh hali kayıtları oluşturun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Ruh hali dağılımını hesapla
    final moodDistribution = _calculateMoodDistribution(moodEntries);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zaman aralığı seçici
          _buildTimeRangeSelector(context),
          
          const SizedBox(height: 24),
          
          // Özet kart
          _buildSummaryCard(context),
          
          const SizedBox(height: 24),
          
          // Ruh hali dağılımı
          Text(
            'Ruh Hali Dağılımı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildMoodDistributionChart(context, moodDistribution),
          
          const SizedBox(height: 24),
          
          // Günlük aktivite
          Text(
            'Günlük Aktivite',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDailyActivityChart(context),
          
          const SizedBox(height: 24),
          
          // En sık kullanılan etiketler
          Text(
            'En Sık Kullanılan Etiketler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopTagsWidget(context),
        ],
      ),
    );
  }
  
  /// Zaman aralığı seçici widget'ı
  Widget _buildTimeRangeSelector(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: timeRanges.map((range) {
          final isSelected = selectedTimeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTimeRangeChanged(range),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Özet kart widget'ı
  Widget _buildSummaryCard(BuildContext context) {
    // En sık kullanılan ruh halini bul
    final moodCounts = <String, int>{};
    for (final entry in moodEntries) {
      moodCounts[entry.moodEmoji] = (moodCounts[entry.moodEmoji] ?? 0) + 1;
    }
    
    String mostFrequentMood = '';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentMood = mood;
      }
    });
    
    // Ortalama günlük giriş sayısı
    final dateSet = <String>{};
    for (final entry in moodEntries) {
      dateSet.add(DateFormat('yyyy-MM-dd').format(entry.createdAt));
    }
    final avgEntriesPerDay = dateSet.isEmpty 
        ? 0.0 
        : moodEntries.length / dateSet.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(76),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$selectedTimeRange Özet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                context,
                'Toplam Kayıt',
                '${moodEntries.length}',
                Icons.list_alt_outlined,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                context,
                'En Sık Ruh Hali',
                mostFrequentMood,
                Icons.emoji_emotions_outlined,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                context,
                'Günlük Ortalama',
                avgEntriesPerDay.toStringAsFixed(1),
                Icons.calendar_today_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Özet öğesi widget'ı
  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Ruh hali dağılımı grafiği
  Widget _buildMoodDistributionChart(BuildContext context, Map<String, int> distribution) {
    // Toplam giriş sayısı
    final totalEntries = distribution.values.fold(0, (sum, count) => sum + count);
    
    return Column(
      children: distribution.entries.map((entry) {
        final mood = entry.key;
        final count = entry.value;
        final percentage = totalEntries > 0 ? count / totalEntries : 0.0;
        final moodColor = AppTheme.moodColors[mood] ?? Colors.grey;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    mood,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMoodLabel(mood),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$count (${(percentage * 100).toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: moodColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: moodColor.withAlpha(51),
                  color: moodColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  /// Günlük aktivite grafiği
  Widget _buildDailyActivityChart(BuildContext context) {
    // Basit bir placeholder grafik
    // Gerçek uygulamada fl_chart gibi bir kütüphane kullanılabilir
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Günlük aktivite grafiği burada gösterilecek',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Gerçek uygulamada fl_chart gibi bir kütüphane kullanılabilir',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// En sık kullanılan etiketler widget'ı
  Widget _buildTopTagsWidget(BuildContext context) {
    // Etiketleri say
    final tagCounts = <String, int>{};
    for (final entry in moodEntries) {
      if (entry.tags != null) {
        for (final tag in entry.tags!) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }
    
    // Sırala
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // En fazla 10 etiket göster
    final topTags = sortedTags.take(10).toList();
    
    if (topTags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            'Henüz etiket kullanılmamış',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: topTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withAlpha(76),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${tag.key}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tag.value}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  /// Ruh hali dağılımını hesaplayan metod
  Map<String, int> _calculateMoodDistribution(List<MoodEntry> entries) {
    final distribution = <String, int>{};
    
    for (final entry in entries) {
      distribution[entry.moodEmoji] = (distribution[entry.moodEmoji] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  /// Emoji için label döndüren metod
  String _getMoodLabel(String emoji) {
    switch (emoji) {
      case '😊':
        return 'Mutlu';
      case '😐':
        return 'Nötr';
      case '😢':
        return 'Üzgün';
      case '😡':
        return 'Kızgın';
      case '😴':
        return 'Yorgun';
      case '🤔':
        return 'Düşünceli';
      case '😍':
        return 'Aşık';
      case '😎':
        return 'Havalı';
      default:
        return 'Bilinmeyen';
    }
  }
}