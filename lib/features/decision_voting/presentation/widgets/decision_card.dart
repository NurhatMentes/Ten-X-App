import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ten_x_app/features/decision_voting/domain/entities/decision.dart';

class DecisionCard extends StatelessWidget {
  final Decision decision;
  final Function(int)? onVote;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const DecisionCard({
    super.key,
    required this.decision,
    this.onVote,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(context),
              const SizedBox(height: 12),
              Text(decision.title, style: Theme.of(context).textTheme.titleLarge),
              if (decision.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    decision.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 16),
              _buildVoteProgress(),
              const SizedBox(height: 16),
              _buildCardFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Chip(
          label: Text(decision.category),
          backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(25),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        if (onEdit != null && onDelete != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit!();
              if (value == 'delete') onDelete!();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildVoteProgress() {
    final winningOptionIndex = decision.winningOption;
    final totalVotes = decision.totalVotes;

    if (totalVotes == 0) {
      return const Text('No votes yet.');
    }

    final winningOptionText = winningOptionIndex != null 
        ? decision.options[winningOptionIndex] 
        : 'Tied';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Winning: $winningOptionText'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: totalVotes > 0 && winningOptionIndex != null 
              ? (decision.getOptionVoteCount(winningOptionIndex) / totalVotes) 
              : 0,
          backgroundColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${decision.totalVotes} votes',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (decision.expiresAt != null)
          Text(
            'Expires ${DateFormat.yMMMd().format(decision.expiresAt!)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Chip(
      label: Text(decision.status.displayName),
      padding: EdgeInsets.zero,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
      backgroundColor: decision.status == DecisionStatus.active
          ? Colors.green
          : decision.status == DecisionStatus.completed
              ? Colors.red
              : Colors.grey,
    );
  }
}