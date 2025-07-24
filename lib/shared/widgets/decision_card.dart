import 'package:flutter/material.dart';
import '../../features/decision_diary/models/decision.dart';

class DecisionCard extends StatelessWidget {
  final Decision decision;
  final Function(String, String) onVote;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const DecisionCard({
    super.key,
    required this.decision,
    required this.onVote,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (decision.priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.medium:
        return Colors.yellow;
      case Priority.low:
        return Colors.green;
    }
  }

  Color _getStatusColor() {
    switch (decision.status) {
      case DecisionStatus.pending:
        return Colors.grey;
      case DecisionStatus.approved:
        return Colors.green;
      case DecisionStatus.rejected:
        return Colors.red;
      case DecisionStatus.inProgress:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (decision.status) {
      case DecisionStatus.pending:
        return 'Beklemede';
      case DecisionStatus.approved:
        return 'Onaylandı';
      case DecisionStatus.rejected:
        return 'Reddedildi';
      case DecisionStatus.inProgress:
        return 'Devam Ediyor';
    }
  }

  String _getPriorityText() {
    switch (decision.priority) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve öncelik
            Row(
              children: [
                Expanded(
                  child: Text(
                    decision.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Açıklama
            Text(
              decision.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            
            // Kategori ve durum
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  decision.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tarih
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${decision.createdAt.day}/${decision.createdAt.month}/${decision.createdAt.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Aksiyon butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Onay butonu
                ElevatedButton.icon(
                  onPressed: () => onVote(decision.id, 'approve'),
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: const Text('Onayla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                
                // Red butonu
                ElevatedButton.icon(
                  onPressed: () => onVote(decision.id, 'reject'),
                  icon: const Icon(Icons.thumb_down, size: 16),
                  label: const Text('Reddet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                
                // Düzenle butonu
                IconButton(
                  onPressed: () => onEdit(decision.id),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Düzenle',
                ),
                
                // Sil butonu
                IconButton(
                  onPressed: () => onDelete(decision.id),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Sil',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}