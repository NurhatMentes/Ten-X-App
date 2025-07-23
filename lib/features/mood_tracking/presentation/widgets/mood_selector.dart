import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_theme.dart';

/// Ruh hali seçici widget'ı
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
          
          // Ruh hali emoji'leri grid'i
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: AppConstants.moodEmojis.length,
            itemBuilder: (context, index) {
              final emoji = AppConstants.moodEmojis[index];
              final isSelected = selectedMood == emoji;
              final moodColor = AppTheme.moodColors[emoji] ?? Colors.grey;
              
              return GestureDetector(
                onTap: () => onMoodSelected(emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
                        _getMoodLabel(emoji),
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
              );
            },
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
                          'Seçili: ${_getMoodLabel(selectedMood!)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.moodColors[selectedMood],
                          ),
                        ),
                        Text(
                          _getMoodDescription(selectedMood!),
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
  
  /// Emoji için açıklama döndüren metod
  String _getMoodDescription(String emoji) {
    switch (emoji) {
      case '😊':
        return 'Kendimi iyi ve pozitif hissediyorum';
      case '😐':
        return 'Normal, ne iyi ne kötü hissediyorum';
      case '😢':
        return 'Üzgün ve melankolik hissediyorum';
      case '😡':
        return 'Sinirli ve öfkeli hissediyorum';
      case '😴':
        return 'Yorgun ve bitkin hissediyorum';
      case '🤔':
        return 'Düşünceli ve kararsız hissediyorum';
      case '😍':
        return 'Aşık ve romantik hissediyorum';
      case '😎':
        return 'Kendimden emin ve havalı hissediyorum';
      default:
        return 'Ruh halim belirsiz';
    }
  }
}