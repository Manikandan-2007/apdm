import React, { useState } from 'react';
import { X, Search, Sparkles } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { SUGGESTION_CATEGORIES, ALL_SUGGESTION_PROMPTS } from '../constants/prompts';

interface InnumPaaruModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectPrompt: (prompt: string) => void;
}

export const InnumPaaruModal: React.FC<InnumPaaruModalProps> = ({
  isOpen,
  onClose,
  onSelectPrompt,
}) => {
  const { palette } = useApp();
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [search, setSearch] = useState<string>('');

  if (!isOpen) return null;

  const filteredPrompts = ALL_SUGGESTION_PROMPTS.filter((item) => {
    const matchesCat =
      selectedCategory === 'all' || item.categoryId === selectedCategory;
    const matchesSearch =
      !search.trim() ||
      item.prompt.toLowerCase().includes(search.toLowerCase()) ||
      item.shortLabel.toLowerCase().includes(search.toLowerCase());
    return matchesCat && matchesSearch;
  });

  return (
    <div
      id="innum-paaru-modal"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/70 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-2xl max-h-[85vh] flex flex-col rounded-t-3xl sm:rounded-3xl shadow-2xl border overflow-hidden transition-all duration-200"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        {/* Header */}
        <div
          className="p-5 pb-3 border-b flex items-center justify-between"
          style={{ borderColor: palette.border }}
        >
          <div>
            <div className="flex items-center gap-2">
              <Sparkles className="w-5 h-5" style={{ color: palette.primary }} />
              <h2
                className="text-lg font-bold tracking-tight"
                style={{ color: palette.textPrimary }}
              >
                Conversation Starters
              </h2>
            </div>
            <p className="text-xs mt-0.5" style={{ color: palette.textSecondary }}>
              Choose a topic tailored for Meenu, Dinesh, Padma, or family memories
            </p>
          </div>
          <button
            onClick={onClose}
            aria-label="Close"
            className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search */}
        <div className="px-5 pt-3">
          <div
            className="flex items-center gap-2 px-3 py-2 rounded-xl border"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <Search className="w-4 h-4" style={{ color: palette.textMuted }} />
            <input
              type="text"
              placeholder="Search topics (Meenu, Dinesh, coffee, business)..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-transparent text-sm outline-none"
              style={{ color: palette.textPrimary }}
            />
          </div>
        </div>

        {/* Category Pills horizontal scroll */}
        <div className="px-5 py-3 flex gap-1.5 overflow-x-auto no-scrollbar">
          <button
            onClick={() => setSelectedCategory('all')}
            className="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors"
            style={{
              backgroundColor:
                selectedCategory === 'all'
                  ? palette.primary
                  : `${palette.border}80`,
              color: selectedCategory === 'all' ? '#ffffff' : palette.textPrimary,
            }}
          >
            All Topics ({ALL_SUGGESTION_PROMPTS.length})
          </button>
          {SUGGESTION_CATEGORIES.map((cat) => {
            const isSelected = selectedCategory === cat.id;
            return (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap flex items-center gap-1.5 transition-colors"
                style={{
                  backgroundColor: isSelected
                    ? palette.primary
                    : `${palette.border}80`,
                  color: isSelected ? '#ffffff' : palette.textPrimary,
                }}
              >
                <span>{cat.icon}</span>
                <span>{cat.title}</span>
              </button>
            );
          })}
        </div>

        {/* Prompts List */}
        <div className="flex-1 overflow-y-auto px-5 py-2 space-y-2">
          {filteredPrompts.length === 0 ? (
            <div className="py-12 text-center text-sm" style={{ color: palette.textMuted }}>
              No prompts found matching your search.
            </div>
          ) : (
            filteredPrompts.map((item, idx) => (
              <button
                key={idx}
                onClick={() => {
                  onSelectPrompt(item.prompt);
                  onClose();
                }}
                className="w-full text-left p-3.5 rounded-xl border text-sm transition-all hover:scale-[1.01] active:scale-[0.99] flex items-center justify-between gap-3"
                style={{
                  backgroundColor: palette.card,
                  borderColor: palette.border,
                  color: palette.textPrimary,
                }}
              >
                <div className="flex-1">
                  <span
                    className="inline-block text-[11px] font-semibold uppercase px-2 py-0.5 rounded-md mb-1"
                    style={{
                      backgroundColor: `${palette.primary}18`,
                      color: palette.primary,
                    }}
                  >
                    {item.shortLabel}
                  </span>
                  <p className="font-medium text-sm leading-snug">{item.prompt}</p>
                </div>
                <span
                  className="text-xs font-medium shrink-0 px-2.5 py-1 rounded-md"
                  style={{
                    backgroundColor: `${palette.primary}15`,
                    color: palette.primary,
                  }}
                >
                  Ask →
                </span>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
