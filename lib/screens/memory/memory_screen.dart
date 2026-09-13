import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/memory.dart';
import '../../services/service_locator.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/memory_card.dart';
import 'add_edit_memory_dialog.dart';
import 'memory_detail_sheet.dart';

/// Memory Screen - preserving stories, quotes, traditions, and memories of the loved one.
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final ServiceLocator _services = ServiceLocator.instance;
  MemoryCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddMemoryDialog() async {
    final newMemory = await showModalBottomSheet<Memory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditMemoryDialog(),
    );

    if (newMemory != null) {
      await _services.memoryService.addMemory(newMemory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cherished memory preserved safely.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openEditMemoryDialog(Memory memory) async {
    final updated = await showModalBottomSheet<Memory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditMemoryDialog(memoryToEdit: memory),
    );

    if (updated != null) {
      await _services.memoryService.updateMemory(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openMemoryDetail(Memory memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryDetailSheet(
        memory: memory,
        onEdit: () => _openEditMemoryDialog(memory),
        onDelete: () => _confirmDeleteMemory(memory),
      ),
    );
  }

  void _confirmDeleteMemory(Memory memory) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: Text('Are you sure you want to remove "${memory.title}" from preserved memories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _services.memoryService.deleteMemory(memory.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memory removed.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pathivu Seidha Ninaivugal'),
            Text(
              'Kudumba Ninaivugal Archive',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: 'Pudhu Ninaivu Saerka',
            onPressed: _openAddMemoryDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_memory',
        onPressed: _openAddMemoryDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ninaivu Saerka', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListenableBuilder(
        listenable: _services.memoryService,
        builder: (context, _) {
          List<Memory> displayedMemories = _services.memoryService.memories;

          // Category filter
          if (_selectedCategory != null) {
            displayedMemories = displayedMemories
                .where((m) => m.category == _selectedCategory)
                .toList();
          }

          // Search query filter
          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase().trim();
            displayedMemories = displayedMemories.where((m) {
              return m.title.toLowerCase().contains(q) ||
                  m.content.toLowerCase().contains(q) ||
                  m.tags.any((t) => t.toLowerCase().contains(q));
            }).toList();
          }

          return Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ninaivugal, kathaigal thedunga...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Category Filter Bar
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryChip(
                        label: 'All Memories',
                        icon: Icons.all_inclusive_rounded,
                        isSelected: _selectedCategory == null,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = null);
                        },
                      ),
                    ),
                    ...MemoryCategory.values.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CategoryChip(
                          category: cat,
                          label: cat.label,
                          icon: cat.icon,
                          isSelected: _selectedCategory == cat,
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = val ? cat : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Memory Cards List or Empty State
              Expanded(
                child: displayedMemories.isEmpty
                    ? EmptyStateView(
                        icon: Icons.auto_stories_outlined,
                        title: _searchQuery.isNotEmpty
                            ? 'No matching memories found'
                            : 'No memories in this category yet',
                        message: _searchQuery.isNotEmpty
                            ? 'Try different keywords or clear the search filter.'
                            : 'Preserve personal anecdotes, lessons, or favorite moments to enrich conversations.',
                        actionLabel: 'Add First Memory',
                        onAction: _openAddMemoryDialog,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayedMemories.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final memory = displayedMemories[index];
                          return MemoryCard(
                            memory: memory,
                            onTap: () => _openMemoryDetail(memory),
                            onEdit: () => _openEditMemoryDialog(memory),
                            onDelete: () => _confirmDeleteMemory(memory),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
