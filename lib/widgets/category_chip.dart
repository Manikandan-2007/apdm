import 'package:flutter/material.dart';
import '../models/memory.dart';

/// Filter chip for memory categories.
class CategoryChip extends StatelessWidget {
  final MemoryCategory? category;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const CategoryChip({
    super.key,
    this.category,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = category?.accentColor ?? theme.colorScheme.primary;

    return FilterChip(
      selected: isSelected,
      onSelected: onSelected,
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : accentColor,
            )
          : null,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? Colors.black
            : (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
      ),
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF1E2638)
          : const Color(0xFFEDE8DF),
      selectedColor: accentColor,
      side: BorderSide(
        color: isSelected
            ? accentColor
            : (theme.brightness == Brightness.dark
                ? const Color(0xFF2C394E)
                : const Color(0xFFDED6C7)),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      showCheckmark: false,
    );
  }
}
