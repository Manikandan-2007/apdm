import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../services/suggestion_service.dart';

/// Modal sheet showing all 80+ suggestions categorized across 12 Tanglish categories.
class InnumPaaruSheet extends StatefulWidget {
  final ValueChanged<String> onSelectPrompt;

  const InnumPaaruSheet({super.key, required this.onSelectPrompt});

  @override
  State<InnumPaaruSheet> createState() => _InnumPaaruSheetState();
}

class _InnumPaaruSheetState extends State<InnumPaaruSheet> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ServiceLocator.instance.themeProvider;
    final palette = themeProvider.currentPalette;
    final isDark = themeProvider.isDarkMode;

    List<SuggestionPrompt> displayed = SuggestionService.allPrompts;
    if (_selectedCategoryId != 'all') {
      displayed = displayed.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      displayed = displayed.where((p) => p.prompt.toLowerCase().contains(q) || p.shortLabel.toLowerCase().contains(q)).toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: palette.border, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title & Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enna pesalaam?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Innum suggestions & conversation topics',
                      style: TextStyle(fontSize: 12.5, color: palette.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? palette.card : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 14, color: palette.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search suggestions (Meenu, Dinesh, Samayal...)',
                  hintStyle: TextStyle(fontSize: 13, color: palette.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: palette.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Filter Tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCategoryTab(
                  id: 'all',
                  title: 'All Topics (${SuggestionService.allPrompts.length})',
                  icon: '✨',
                  isSelected: _selectedCategoryId == 'all',
                  palette: palette,
                ),
                ...SuggestionService.categories.map((cat) {
                  final count = SuggestionService.getPromptsByCategory(cat.id).length;
                  return _buildCategoryTab(
                    id: cat.id,
                    title: '${cat.title} ($count)',
                    icon: cat.icon,
                    isSelected: _selectedCategoryId == cat.id,
                    palette: palette,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: palette.border, height: 1),

          // Suggestion Prompts List
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Text(
                      'No suggestions found.',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayed.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = displayed[index];
                      final category = SuggestionService.categories.firstWhere(
                        (c) => c.id == item.categoryId,
                        orElse: () => SuggestionService.categories.first,
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onSelectPrompt(item.prompt);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? palette.card : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.icon, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.prompt,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: palette.textPrimary,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.title,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: palette.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: palette.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String id,
    required String title,
    required String icon,
    required bool isSelected,
    required dynamic palette,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Text(icon, style: const TextStyle(fontSize: 13)),
        label: Text(title),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.black : palette.textSecondary,
        ),
        backgroundColor: palette.card,
        selectedColor: palette.primary,
        side: BorderSide(
          color: isSelected ? palette.primary : palette.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => setState(() => _selectedCategoryId = id),
      ),
    );
  }
}
