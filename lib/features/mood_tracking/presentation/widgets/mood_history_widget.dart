import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;

/// Ruh hali geçmişi widget'ı
class MoodHistoryWidget extends StatelessWidget {
  /// Ruh hali girişleri listesi
  final List<MoodEntry> moodEntries;
  
  /// Ruh hali girişi düzenlendiğinde çağrılacak callback
  final Function(MoodEntry)? onEditEntry;
  
  /// Ruh hali girişi silindiğinde çağrılacak callback
  final Function(String)? onDeleteEntry;
  
  /// Loading durumu
  final bool isLoading;
  
  /// MoodHistoryWidget constructor'ı
  const MoodHistoryWidget({
    super.key,
    required this.moodEntries,
    this.onEditEntry,
    this.onDeleteEntry,
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
              Icons.mood_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz ruh hali kaydınız yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk ruh hali kaydınızı oluşturmak için\n"Bugün" sekmesini kullanın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Tarihe göre gruplandırılmış girişler
    final groupedEntries = _groupEntriesByDate(moodEntries);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final dateKey = groupedEntries.keys.elementAt(index);
        final entries = groupedEntries[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarih başlığı
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(dateKey),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            // O tarihteki girişler
            ...entries.map((entry) => _buildMoodEntryCard(context, entry)),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
  
  /// Ruh hali girişi kartı oluşturan metod
  Widget _buildMoodEntryCard(BuildContext context, MoodEntry entry) {
    final moodColor = AppTheme.moodColors[entry.moodEmoji] ?? Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onEditEntry?.call(entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ruh hali emoji'si
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: moodColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.moodEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Zaman ve açıklama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(entry.createdAt),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: moodColor,
                          ),
                        ),
                        if (entry.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            entry.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Menü butonu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditEntry?.call(entry);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, entry);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Ek bilgiler (aktivite, etiketler, konum)
              if (entry.activity?.isNotEmpty == true ||
                  entry.tags?.isNotEmpty == true ||
                  entry.location?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (entry.activity?.isNotEmpty == true)
                      _buildInfoChip(
                        context,
                        Icons.local_activity_outlined,
                        entry.activity!,
                      ),
                    if (entry.location?.isNotEmpty == true)
                      _buildInfoChip(
                        context,
                        Icons.location_on_outlined,
                        entry.location!,
                      ),
                    if (entry.tags?.isNotEmpty == true)
                      ...entry.tags!.map(
                        (tag) => _buildInfoChip(
                          context,
                          Icons.tag,
                          tag,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Bilgi chip'i oluşturan metod
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Silme onayı dialog'u gösteren metod
  void _showDeleteConfirmation(BuildContext context, MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ruh Hali Kaydını Sil'),
        content: const Text(
          'Bu ruh hali kaydını silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteEntry?.call(entry.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
  
  /// Girişleri tarihe göre gruplandıran metod
  Map<String, List<MoodEntry>> _groupEntriesByDate(List<MoodEntry> entries) {
    final Map<String, List<MoodEntry>> grouped = {};
    
    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }
    
    // Her grup içindeki girişleri zamana göre sırala (en yeni önce)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }
  
  /// Tarih başlığını formatlayan metod
  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    
        if (app_date_utils.AppDateUtils.isToday(date)) {
      return 'Bugün';
        } else if (app_date_utils.AppDateUtils.isYesterday(date)) {
      return 'Dün';
    } else {
      return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
    }
  }
}