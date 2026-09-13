import 'package:flutter/material.dart';
import '../../models/memorial_profile.dart';

/// Modal dialog/sheet to update the Memorial Profile configuration.
class EditProfileDialog extends StatefulWidget {
  final MemorialProfile currentProfile;

  const EditProfileDialog({super.key, required this.currentProfile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _lifespanController;
  late TextEditingController _bioController;
  late TextEditingController _phraseController;

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _nameController = TextEditingController(text: p.lovedOneName);
    _relationshipController = TextEditingController(text: p.relationship);
    _lifespanController = TextEditingController(text: p.lifespan);
    _bioController = TextEditingController(text: p.biography);
    _phraseController = TextEditingController(text: p.favoritePhrase);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _lifespanController.dispose();
    _bioController.dispose();
    _phraseController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'AP';

    final updated = widget.currentProfile.copyWith(
      lovedOneName: name,
      relationship: _relationshipController.text.trim(),
      lifespan: _lifespanController.text.trim(),
      biography: _bioController.text.trim(),
      favoritePhrase: _phraseController.text.trim(),
      avatarInitials: initials,
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Memorial Profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Loved One\'s Name',
                    hintText: 'e.g. Eleanor Rose',
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _relationshipController,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          hintText: 'e.g. Grandmother',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lifespanController,
                        decoration: const InputDecoration(
                          labelText: 'Lifespan Years',
                          hintText: 'e.g. 1942 – 2021',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phraseController,
                  decoration: const InputDecoration(
                    labelText: 'Memorable Quote / Favorite Saying',
                    hintText: 'e.g. "Kindness is the one seed that always blossoms."',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Biographical Context & Personality',
                    hintText: 'Briefly describe their passions, personality, and cherished values...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Update Memorial Space'),
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
