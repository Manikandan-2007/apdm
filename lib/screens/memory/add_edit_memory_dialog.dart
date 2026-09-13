import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/memory.dart';

/// Modal dialog/sheet to add a new memory or edit an existing one.
class AddEditMemoryDialog extends StatefulWidget {
  final Memory? memoryToEdit;

  const AddEditMemoryDialog({super.key, this.memoryToEdit});

  @override
  State<AddEditMemoryDialog> createState() => _AddEditMemoryDialogState();
}

class _AddEditMemoryDialogState extends State<AddEditMemoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _emotionController;

  late MemoryCategory _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final mem = widget.memoryToEdit;
    _titleController = TextEditingController(text: mem?.title ?? '');
    _contentController = TextEditingController(text: mem?.content ?? '');
    _tagsController = TextEditingController(text: mem?.tags.join(', ') ?? '');
    _emotionController = TextEditingController(text: mem?.emotionTag ?? '');
    _selectedCategory = mem?.category ?? MemoryCategory.family;
    _selectedDate = mem?.memoryDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _emotionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final isEditing = widget.memoryToEdit != null;
    final memory = Memory(
      id: isEditing ? widget.memoryToEdit!.id : 'mem_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      memoryDate: _selectedDate,
      createdAt: isEditing ? widget.memoryToEdit!.createdAt : DateTime.now(),
      tags: tags,
      emotionTag: _emotionController.text.trim().isNotEmpty ? _emotionController.text.trim() : null,
    );

    Navigator.of(context).pop(memory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.memoryToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF171F2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dialog Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Preserved Memory' : 'Preserve a New Memory',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category Selector
                const Text(
                  'Memory Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MemoryCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                      avatar: Icon(
                        cat.icon,
                        size: 15,
                        color: isSelected ? Colors.black : cat.accentColor,
                      ),
                      label: Text(cat.label),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.black : null,
                      ),
                      selectedColor: cat.accentColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Memory Title',
                    hintText: 'e.g. Sunday Roast & Cinnamon Apple Pie',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please provide a title' : null,
                ),
                const SizedBox(height: 16),

                // Memory Content / Story Input
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'The Story / Memory Content',
                    hintText: 'Describe this cherished memory, words spoken, or the lesson learned...',
                    alignLabelWithHint: true,
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please describe the memory' : null,
                ),
                const SizedBox(height: 16),

                // Memory Date & Emotion Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Approximate Date',
                            suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? DateFormat('MMM d, y').format(_selectedDate!)
                                : 'Select date',
                            style: TextStyle(
                              color: _selectedDate != null ? null : theme.hintColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emotionController,
                        decoration: const InputDecoration(
                          labelText: 'Emotion / Tone',
                          hintText: 'e.g. Warm, Peaceful',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags Input
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'e.g. Gardening, Wisdom, Family',
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Changes' : 'Preserve Memory'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
