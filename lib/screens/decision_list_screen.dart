import 'package:flutter/material.dart';
import '../shared/widgets/decision_card.dart';
import '../shared/widgets/create_decision_dialog.dart';
import '../features/decision_diary/models/decision.dart';

class DecisionListScreen extends StatefulWidget {
  const DecisionListScreen({super.key});

  @override
  State<DecisionListScreen> createState() => _DecisionListScreenState();
}

class _DecisionListScreenState extends State<DecisionListScreen> {
  List<Decision> decisions = [
    Decision(
      id: '1',
      title: 'Yeni iş teklifi kabul edilsin mi?',
      description: 'Daha yüksek maaş ama uzak lokasyon',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: DecisionStatus.pending,
      category: 'Kariyer',
      priority: Priority.high,
    ),
    Decision(
      id: '2',
      title: 'Yeni ev alınmalı mı?',
      description: 'Şehir merkezinde ama pahalı',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      status: DecisionStatus.pending,
      category: 'Yaşam',
      priority: Priority.medium,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ten-X Kararlarım'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtreleme fonksiyonu
            },
          ),
        ],
      ),
      body: decisions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz karar eklenmemiş',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'İlk kararınızı eklemek için + butonuna basın',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decisions.length,
              itemBuilder: (context, index) {
                final decision = decisions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DecisionCard(
                    decision: decision,
                    onVote: (decisionId, vote) {
                      // Oylama fonksiyonu
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Oy verildi: $vote'),
                        ),
                      );
                    },
                    onEdit: (decisionId) {
                      // Düzenleme fonksiyonu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Düzenleme özelliği yakında gelecek'),
                        ),
                      );
                    },
                    onDelete: (decisionId) {
                      // Silme fonksiyonu
                      setState(() {
                        decisions.removeWhere((d) => d.id == decisionId);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Karar silindi'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateDecisionDialog(
              onDecisionCreated: (decision) {
                setState(() {
                  decisions.add(decision);
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}