import 'package:flutter/material.dart';
import '../../features/decision_diary/models/decision.dart';

class CreateDecisionDialog extends StatefulWidget {
  final Function(Decision) onDecisionCreated;

  const CreateDecisionDialog({
    super.key,
    required this.onDecisionCreated,
  });

  @override
  State<CreateDecisionDialog> createState() => _CreateDecisionDialogState();
}

class _CreateDecisionDialogState extends State<CreateDecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return 'Acil';
      case Priority.high:
        return 'Yüksek';
      case Priority.medium:
        return 'Orta';
      case Priority.low:
        return 'Düşük';
    }
  }

  void _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _createDecision() {
    if (_formKey.currentState!.validate()) {
      final decision = Decision(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty 
            ? 'Genel' 
            : _categoryController.text.trim(),
        priority: _selectedPriority,
        status: DecisionStatus.pending,
        createdAt: DateTime.now(),
        deadline: _selectedDeadline,
      );
      
      widget.onDecisionCreated(decision);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Text(
                'Yeni Karar Ekle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Karar başlığı
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Karar Başlığı *',
                  hintText: 'Örn: Yeni iş teklifi kabul edilsin mi?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Karar başlığı gereklidir';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              
              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  hintText: 'Karar hakkında detaylı bilgi...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama gereklidir';
                  }
                  return null;
                },
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              
              // Kategori
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Örn: Kariyer, Yaşam, Finans',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              
              // Öncelik seçimi
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Öncelik',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityText(priority)),
                  );
                }).toList(),
                onChanged: (Priority? value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Son tarih seçimi
              InkWell(
                onTap: _selectDeadline,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Son Tarih (İsteğe bağlı)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDeadline != null
                        ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _selectedDeadline != null 
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: _createDecision,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Karar Ekle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}