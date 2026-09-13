import 'package:flutter/material.dart';
import '../models/language.dart';

class SuggestionPrompt {
  final String text;
  final AppLanguage language;
  final IconData icon;

  const SuggestionPrompt({
    required this.text,
    required this.language,
    required this.icon,
  });
}

/// Contextual multilingual starter prompts for empty conversations.
class SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelectPrompt;

  const SuggestionChips({super.key, required this.onSelectPrompt});

  static const List<SuggestionPrompt> prompts = [
    SuggestionPrompt(
      text: 'Appavin ninaivugal patri sollunga',
      language: AppLanguage.tanglish,
      icon: Icons.auto_stories_rounded,
    ),
    SuggestionPrompt(
      text: 'Appa, innikku romba kashtama irukku.',
      language: AppLanguage.tanglish,
      icon: Icons.sentiment_neutral_rounded,
    ),
    SuggestionPrompt(
      text: 'Can you tell me something about my childhood?',
      language: AppLanguage.english,
      icon: Icons.child_care_rounded,
    ),
    SuggestionPrompt(
      text: 'Appa oda morning coffee routine enna?',
      language: AppLanguage.tanglish,
      icon: Icons.coffee_rounded,
    ),
    SuggestionPrompt(
      text: 'What was his timeless advice on patience?',
      language: AppLanguage.english,
      icon: Icons.lightbulb_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUGGESTED CONVERSATIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: isDark ? const Color(0xFF7A889B) : const Color(0xFF9E9589),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts.map((p) {
              return ActionChip(
                avatar: Icon(p.icon, size: 16, color: Theme.of(context).colorScheme.primary),
                label: Text(p.text),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                backgroundColor: isDark ? const Color(0xFF1B2332) : const Color(0xFFF3ECE1),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C394E) : const Color(0xFFDFD6C7),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                onPressed: () => onSelectPrompt(p.text),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
