import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_theme.dart';

/// Ruh hali seçici widget'ı - Optimize edilmiş versiyon
class MoodSelector extends StatelessWidget {
  /// Seçili ruh hali emoji
  final String? selectedMood;
  
  /// Ruh hali seçildiğinde çağrılacak callback
  final Function(String) onMoodSelected;
  
  /// MoodSelector constructor'ı
  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });
  
  /// Emoji listesi - const olarak tanımla
  static const List<String> _moodEmojis = [
    '😊', '😐', '😢', '😡', '😴', '🤔', '😍', '😎'
  ];
  
  /// Mood labels - const map olarak tanımla
  static const Map<String, String> _moodLabels = {
    '😊': 'Mutlu',
    '😐': 'Nötr', 
    '😢': 'Üzgün',
    '😡': 'Kızgın',
    '😴': 'Yorgun',
    '🤔': 'Düşünceli',
    '😍': 'Aşık',
    '😎': 'Havalı',
  };
  
  /// Mood descriptions - const map olarak tanımla
  static const Map<String, String> _moodDescriptions = {
    '😊': 'Kendimi iyi ve pozitif hissediyorum',
    '😐': 'Normal, ne iyi ne kötü hissediyorum',
    '😢': 'Üzgün ve melankolik hissediyorum',
    '😡': 'Sinirli ve öfkeli hissediyorum',
    '😴': 'Yorgun ve bitkin hissediyorum',
    '🤔': 'Düşünceli ve kararsız hissediyorum',
    '😍': 'Aşık ve romantik hissediyorum',
    '😎': 'Kendimden emin ve havalı hissediyorum',
  };
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ruh halinizi seçin:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ruh hali emoji'leri grid'i - Optimize edilmiş versiyon
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _moodEmojis.map((emoji) {
              return _MoodButton(
                emoji: emoji,
                isSelected: selectedMood == emoji,
                onTap: () => onMoodSelected(emoji),
                label: _moodLabels[emoji] ?? 'Bilinmeyen',
              );
            }).toList(),
          ),
          
          if (selectedMood != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.moodColors[selectedMood]?.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.moodColors[selectedMood] ?? Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    selectedMood!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seçili: ${_moodLabels[selectedMood!] ?? 'Bilinmeyen'}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.moodColors[selectedMood],
                          ),
                        ),
                        Text(
                          _moodDescriptions[selectedMood!] ?? 'Ruh halim belirsiz',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
}

/// Optimize edilmiş ruh hali butonu widget'ı
class _MoodButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  
  const _MoodButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final moodColor = AppTheme.moodColors[emoji] ?? Colors.grey;
    
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 80) / 4,
      height: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? moodColor.withAlpha(51)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? moodColor
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: isSelected ? 32 : 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                  color: isSelected 
                      ? moodColor
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}