import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../services/suggestion_service.dart';
import 'innum_paaru_sheet.dart';

/// Unique interactive suggested conversation starters with instant category filtering and 'Innum paaru' sheet.
class SuggestedConversationsBar extends StatefulWidget {
  final ValueChanged<String> onSelectSuggestion;

  const SuggestedConversationsBar({super.key, required this.onSelectSuggestion});

  @override
  State<SuggestedConversationsBar> createState() => _SuggestedConversationsBarState();
}

class _SuggestedConversationsBarState extends State<SuggestedConversationsBar> {
  int _rotationSeed = 1;
  String _selectedCategoryId = 'featured'; // 'featured' or categoryId

  @override
  void initState() {
    super.initState();
    _rotationSeed = DateTime.now().microsecondsSinceEpoch % 10000;
  }

  void _refreshSuggestions() {
    setState(() {
      _rotationSeed = DateTime.now().microsecondsSinceEpoch % 10000;
    });
  }

  void _openInnumPaaruSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InnumPaaruSheet(onSelectPrompt: widget.onSelectSuggestion),
    );
  }

  List<SuggestionPrompt> _getCurrentPrompts() {
    if (_selectedCategoryId == 'featured') {
      return SuggestionService.getFeaturedSuggestions(seed: _rotationSeed);
    } else {
      return SuggestionService.getPromptsByCategory(_selectedCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;
    final prompts = _getCurrentPrompts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header Row: "Enna pesalaam?" + Shuffle + "Innum paaru"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: palette.primary.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 15, color: palette.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'Enna pesalaam?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              // Shuffle button
              IconButton(
                icon: Icon(Icons.shuffle_rounded, size: 18, color: palette.textMuted),
                tooltip: 'Vera maathunga (Shuffle)',
                visualDensity: VisualDensity.compact,
                onPressed: _refreshSuggestions,
              ),
              // "Innum paaru" Action Link Pill
              InkWell(
                onTap: _openInnumPaaruSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: palette.primary.withAlpha(isDark ? 30 : 18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: palette.primary.withAlpha(isDark ? 70 : 50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Innum paaru',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: palette.primary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: palette.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 2. Category Filter Pills Bar
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            physics: const BouncingScrollPhysics(),
            children: [
              // Featured "Ellam" Chip
              _buildFilterChip(
                id: 'featured',
                icon: '✨',
                label: 'Ellam',
                palette: palette,
                isDark: isDark,
              ),
              ...SuggestionService.categories.map((cat) => _buildFilterChip(
                    id: cat.id,
                    icon: cat.icon,
                    label: cat.title,
                    palette: palette,
                    isDark: isDark,
                  )),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3. Unique Glassmorphic Suggestions Cards
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: prompts.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == prompts.length) {
                // "Innum paaru" end card
                return InkWell(
                  onTap: _openInnumPaaruSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          palette.primary.withAlpha(isDark ? 45 : 25),
                          palette.primary.withAlpha(isDark ? 20 : 10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: palette.primary.withAlpha(isDark ? 90 : 70),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: palette.primary.withAlpha(isDark ? 50 : 30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.explore_rounded, size: 20, color: palette.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Innum paaru',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = prompts[index];
              final category = SuggestionService.categories.firstWhere(
                (c) => c.id == item.categoryId,
                orElse: () => SuggestionService.categories.first,
              );

              return InkWell(
                onTap: () => widget.onSelectSuggestion(item.prompt),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark
                            ? palette.card.withAlpha(240)
                            : Colors.white,
                        isDark
                            ? palette.card
                            : palette.primary.withAlpha(12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: palette.primary.withAlpha(isDark ? 50 : 35),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withAlpha(isDark ? 20 : 8),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card Top Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: palette.primary.withAlpha(isDark ? 35 : 20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(category.icon, style: const TextStyle(fontSize: 11.5)),
                                const SizedBox(width: 4),
                                Text(
                                  category.title,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: palette.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: palette.primary.withAlpha(140),
                          ),
                        ],
                      ),
                      // Card Prompt Text
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.prompt,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String icon,
    required String label,
    required dynamic palette,
    required bool isDark,
  }) {
    final isSelected = _selectedCategoryId == id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategoryId = id;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? palette.primary
                  : (isDark ? palette.card : Colors.white.withAlpha(200)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? palette.primary
                    : palette.border.withAlpha(isDark ? 80 : 120),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: palette.primary.withAlpha(isDark ? 70 : 40),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : palette.textPrimary,
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
