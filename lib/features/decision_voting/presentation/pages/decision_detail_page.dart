import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ten_x_app/features/decision_voting/domain/entities/decision.dart';
import 'package:ten_x_app/features/decision_voting/presentation/bloc/decision_bloc.dart';
import 'package:ten_x_app/features/decision_voting/presentation/bloc/decision_event.dart';
import 'package:ten_x_app/features/decision_voting/presentation/bloc/decision_state.dart';

class DecisionDetailPage extends StatelessWidget {
  final String decisionId;

  const DecisionDetailPage({super.key, required this.decisionId});

  @override
  Widget build(BuildContext context) {
    // Fetch the decision when the page is loaded
    context.read<DecisionBloc>().add(GetDecisionEvent(decisionId: decisionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Details'),
      ),
      body: BlocConsumer<DecisionBloc, DecisionState>(
        listener: (context, state) {
          if (state is DecisionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          } else if (state is VoteSubmitted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vote submitted successfully!')),
            );
          }
        },
        builder: (context, state) {
          if (state is DecisionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DecisionLoaded) {
            return _buildDecisionDetails(context, state.decision);
          }
          // In case the state is something else (e.g., initial or after an action)
          // you might want to show the last known decision or a specific message.
          // For simplicity, we'll just show a loading indicator if no decision is loaded.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDecisionDetails(BuildContext context, Decision decision) {
    final String userId = 'current_user_id'; // Replace with actual user ID
    final bool hasVoted = decision.hasUserVoted(userId);
    final bool canVote = decision.isActive && (!hasVoted || decision.allowMultipleVotes);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(decision.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          _buildMetaInfo(context, decision),
          const SizedBox(height: 16),
          if (decision.imageUrl?.isNotEmpty == true)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(decision.imageUrl!),
            ),
          const SizedBox(height: 16),
          if (decision.description?.isNotEmpty == true)
            Text(decision.description!, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Options', style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          ..._buildOptionList(context, decision, canVote, userId),
          const SizedBox(height: 24),
          _buildVotingStatus(context, decision, hasVoted, canVote),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context, Decision decision) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Chip(label: Text(decision.category)),
        Chip(label: Text(decision.visibility.displayName)),
        if (decision.isAnonymous) const Chip(label: Text('Anonymous')),
        if (decision.expiresAt != null)
          Chip(label: Text('Expires: ${DateFormat.yMMMd().format(decision.expiresAt!)}')),
      ],
    );
  }

  List<Widget> _buildOptionList(BuildContext context, Decision decision, bool canVote, String userId) {
    return decision.options.asMap().entries.map((entry) {
      int idx = entry.key;
      String option = entry.value;
      int voteCount = decision.getOptionVoteCount(idx);
      double percentage = decision.getOptionPercentage(idx);
      bool isSelected = decision.getUserVotes(userId).contains(idx);

      return ListTile(
        title: Text(option),
        subtitle: LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
        ),
        trailing: Text('${(percentage * 100).toStringAsFixed(1)}% ($voteCount)'),
        onTap: canVote
            ? () {
                context.read<DecisionBloc>().add(VoteDecisionEvent(decisionId: decision.id, userId: userId, optionIndex: idx));
              }
            : null,
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.secondary.withAlpha(51),
      );
    }).toList();
  }

  Widget _buildVotingStatus(BuildContext context, Decision decision, bool hasVoted, bool canVote) {
    if (!decision.isActive) {
      return const Text('This decision is closed.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    }
    if (hasVoted && !decision.allowMultipleVotes) {
      return const Text('You have already voted.', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    }
    if (canVote) {
      return const Text('Select an option to cast your vote.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    }
    return const SizedBox.shrink();
  }
}