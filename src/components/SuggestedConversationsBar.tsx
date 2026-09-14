import React, { useState } from 'react';
import { Sparkles, Layers } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { SUGGESTION_CATEGORIES, ALL_SUGGESTION_PROMPTS } from '../constants/prompts';
import { InnumPaaruModal } from './InnumPaaruModal';

interface SuggestedConversationsBarProps {
  onSelectSuggestion: (prompt: string) => void;
}

export const SuggestedConversationsBar: React.FC<SuggestedConversationsBarProps> = ({
  onSelectSuggestion,
}) => {
  const { palette, activeSpeaker } = useApp();
  const [selectedCatId, setSelectedCatId] = useState<string>(() => {
    if (activeSpeaker === 'dinesh') return 'dinesh';
    if (activeSpeaker === 'padma') return 'padma';
    return 'meenu';
  });
  const [isInnumPaaruOpen, setIsInnumPaaruOpen] = useState<boolean>(false);

  // Sync with activeSpeaker when it changes
  React.useEffect(() => {
    if (activeSpeaker === 'dinesh') setSelectedCatId('dinesh');
    else if (activeSpeaker === 'padma') setSelectedCatId('padma');
    else if (activeSpeaker === 'meenu') setSelectedCatId('meenu');
  }, [activeSpeaker]);

  const activeCategoryPrompts = ALL_SUGGESTION_PROMPTS.filter(
    (p) => p.categoryId === selectedCatId
  ).slice(0, 4);

  return (
    <div id="suggested-conversations-section" className="w-full max-w-xl mx-auto space-y-4">
      {/* Category Pills Header */}
      <div className="flex items-center justify-between px-1">
        <div className="flex items-center gap-2">
          <Sparkles className="w-4 h-4" style={{ color: palette.primary }} />
          <span className="text-xs font-semibold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
            Conversation Starters
          </span>
        </div>
        <button
          onClick={() => setIsInnumPaaruOpen(true)}
          className="text-xs font-semibold flex items-center gap-1.5 px-2.5 py-1 rounded-lg transition-transform active:scale-95 hover:opacity-90"
          style={{
            backgroundColor: `${palette.primary}20`,
            color: palette.primary,
          }}
        >
          <Layers className="w-3.5 h-3.5" />
          <span>Explore All (80+)</span>
        </button>
      </div>

      {/* Category Horizontal Chips */}
      <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
        {SUGGESTION_CATEGORIES.slice(0, 7).map((cat) => {
          const isSelected = selectedCatId === cat.id;
          return (
            <button
              key={cat.id}
              onClick={() => setSelectedCatId(cat.id)}
              className="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-all flex items-center gap-1.5 active:scale-95"
              style={{
                backgroundColor: isSelected ? palette.primary : palette.card,
                color: isSelected ? '#ffffff' : palette.textPrimary,
                border: `1px solid ${isSelected ? palette.primary : palette.border}`,
              }}
            >
              <span>{cat.icon}</span>
              <span>{cat.shortChip}</span>
            </button>
          );
        })}
      </div>

      {/* Suggestion Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        {activeCategoryPrompts.map((item, idx) => (
          <button
            key={idx}
            onClick={() => onSelectSuggestion(item.prompt)}
            className="p-3 rounded-2xl border text-left text-xs transition-all hover:translate-y-[-1px] active:scale-[0.98] shadow-sm flex flex-col justify-between"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
              color: palette.textPrimary,
            }}
          >
            <span
              className="inline-block self-start text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md mb-1.5"
              style={{
                backgroundColor: `${palette.primary}18`,
                color: palette.primary,
              }}
            >
              {item.shortLabel}
            </span>
            <p className="font-medium text-xs leading-relaxed">{item.prompt}</p>
          </button>
        ))}
      </div>

      <InnumPaaruModal
        isOpen={isInnumPaaruOpen}
        onClose={() => setIsInnumPaaruOpen(false)}
        onSelectPrompt={onSelectSuggestion}
      />
    </div>
  );
};
