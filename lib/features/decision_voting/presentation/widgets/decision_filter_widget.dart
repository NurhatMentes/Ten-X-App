import 'package:flutter/material.dart';

class DecisionFilterWidget extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const DecisionFilterWidget({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<String> categories = [
    'Genel',
    'Teknoloji',
    'Sağlık',
    'Eğitim',
    'Spor',
    'Sanat',
    'Müzik',
    'Film',
    'Yemek',
    'Seyahat',
    'İş',
    'Aile',
    'Arkadaşlık',
    'Alışveriş',
    'Moda',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "Tümü" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Tümü" seçeneği
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Tümü'),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    onCategoryChanged(null);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          
          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (selected) {
                onCategoryChanged(selected ? category : null);
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}