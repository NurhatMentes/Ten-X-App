import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ten_x_app/features/decision_voting/domain/entities/decision.dart';
import 'package:ten_x_app/features/decision_voting/presentation/bloc/decision_bloc.dart';
import 'package:ten_x_app/features/decision_voting/presentation/bloc/decision_event.dart';

class CreateDecisionDialog extends StatefulWidget {
  final Decision? decision;

  const CreateDecisionDialog({super.key, this.decision});

  @override
  CreateDecisionDialogState createState() => CreateDecisionDialogState();
}

class CreateDecisionDialogState extends State<CreateDecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _tagsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _locationController;

  String _category = 'General';
  DecisionVisibility _visibility = DecisionVisibility.public;
  DateTime? _expiresAt;
  int? _minVotes;
  int? _maxVotes;
  bool _allowMultipleVotes = false;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    final decision = widget.decision;
    _titleController = TextEditingController(text: decision?.title ?? '');
    _descriptionController = TextEditingController(text: decision?.description ?? '');
    _optionControllers = decision?.options.map((opt) => TextEditingController(text: opt)).toList() ??
        [TextEditingController(), TextEditingController()];
    _tagsController = TextEditingController(text: decision?.tags?.join(', ') ?? '');
    _imageUrlController = TextEditingController(text: decision?.imageUrl ?? '');
    _locationController = TextEditingController(text: decision?.location ?? '');

    _category = decision?.category ?? 'General';
    _visibility = decision?.visibility ?? DecisionVisibility.public;
    _expiresAt = decision?.expiresAt;
    _minVotes = decision?.minVotes;
    _maxVotes = decision?.maxVotes;
    _allowMultipleVotes = decision?.allowMultipleVotes ?? false;
    _isAnonymous = decision?.isAnonymous ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _tagsController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index).dispose();
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expiresAt) {
      setState(() {
        _expiresAt = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final userId = 'current_user_id'; // Replace with actual user ID
      final options = _optionControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();
      final tags = _tagsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      if (widget.decision == null) {
        // Create new decision
        final newDecision = Decision(
          id: '',
          userId: userId,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          options: options,
          votes: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expiresAt: _expiresAt,
          status: DecisionStatus.active,
          visibility: _visibility,
          tags: tags,
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          minVotes: _minVotes,
          maxVotes: _maxVotes,
          allowMultipleVotes: _allowMultipleVotes,
          isAnonymous: _isAnonymous,
        );
        context.read<DecisionBloc>().add(CreateDecisionEvent(decision: newDecision));
      } else {
        // Update existing decision
        final updatedDecision = widget.decision!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category,
          options: options,
          expiresAt: _expiresAt,
          visibility: _visibility,
          tags: tags,
          imageUrl: _imageUrlController.text,
          location: _locationController.text,
          minVotes: _minVotes,
          maxVotes: _maxVotes,
          allowMultipleVotes: _allowMultipleVotes,
          isAnonymous: _isAnonymous,
          updatedAt: DateTime.now(),
        );
        context.read<DecisionBloc>().add(UpdateDecisionEvent(decision: updatedDecision));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.decision == null ? 'Create Decision' : 'Edit Decision'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Options', style: Theme.of(context).textTheme.titleMedium),
              ..._buildOptionFields(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
                onPressed: _addOption,
              ),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              _buildVisibilitySelector(),
              _buildExpiryDateSelector(context),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (Optional)'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Min Votes (Optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _minVotes = int.tryParse(value),
                initialValue: _minVotes?.toString() ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Max Votes (Optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _maxVotes = int.tryParse(value),
                initialValue: _maxVotes?.toString() ?? '',
              ),
              SwitchListTile(
                title: const Text('Allow Multiple Votes'),
                value: _allowMultipleVotes,
                onChanged: (value) => setState(() => _allowMultipleVotes = value),
              ),
              SwitchListTile(
                title: const Text('Anonymous Voting'),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.decision == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  List<Widget> _buildOptionFields() {
    return List.generate(_optionControllers.length, (index) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(labelText: 'Option ${index + 1}'),
              validator: (value) {
                if (value!.isEmpty && index < 2) {
                  return 'Option ${index + 1} is required';
                }
                return null;
              },
            ),
          ),
          if (_optionControllers.length > 2)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _removeOption(index),
            ),
        ],
      );
    });
  }

  Widget _buildCategorySelector() {
    // In a real app, categories would likely come from a remote source or constants
    const categories = ['General', 'Technology', 'Food', 'Travel', 'Work', 'Fun'];
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: const InputDecoration(labelText: 'Category'),
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _category = newValue!;
        });
      },
    );
  }

  Widget _buildVisibilitySelector() {
    return DropdownButtonFormField<DecisionVisibility>(
      value: _visibility,
      decoration: const InputDecoration(labelText: 'Visibility'),
      items: DecisionVisibility.values.map((DecisionVisibility visibility) {
        return DropdownMenuItem<DecisionVisibility>(
          value: visibility,
          child: Text(visibility.displayName),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _visibility = newValue!;
        });
      },
    );
  }

  Widget _buildExpiryDateSelector(BuildContext context) {
    return ListTile(
      title: const Text('Expiry Date'),
      subtitle: Text(_expiresAt == null ? 'Not set' : DateFormat.yMMMd().format(_expiresAt!)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectExpiryDate(context),
    );
  }
}