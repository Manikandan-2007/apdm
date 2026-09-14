import React, { useState } from 'react';
import { Plus, Search, BookOpen, Calendar, Tag } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { Memory, MemoryCategoryType } from '../types';
import { CATEGORY_CONFIG } from '../constants/theme';
import { AddEditMemoryModal } from './AddEditMemoryModal';
import { MemoryDetailModal } from './MemoryDetailModal';

interface MemoriesScreenProps {
  onReflectInChat: (prompt: string) => void;
}

export const MemoriesScreen: React.FC<MemoriesScreenProps> = ({ onReflectInChat }) => {
  const { palette, memories, profile } = useApp();

  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<MemoryCategoryType | 'all'>('all');
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [selectedMemoryForDetail, setSelectedMemoryForDetail] = useState<Memory | null>(null);
  const [memoryToEdit, setMemoryToEdit] = useState<Memory | null>(null);

  const filteredMemories = memories.filter((m) => {
    const matchesCategory =
      selectedCategory === 'all' || m.category === selectedCategory;
    const matchesSearch =
      !search.trim() ||
      m.title.toLowerCase().includes(search.toLowerCase()) ||
      m.content.toLowerCase().includes(search.toLowerCase()) ||
      m.tags.some((t) => t.toLowerCase().includes(search.toLowerCase()));
    return matchesCategory && matchesSearch;
  });

  return (
    <div
      id="memories-screen"
      className="flex flex-col h-full overflow-hidden select-none"
      style={{ backgroundColor: palette.background }}
    >
      {/* Top Header */}
      <header
        className="px-4 py-3 border-b flex items-center justify-between shrink-0 shadow-sm transition-colors"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        <div className="flex items-center gap-2.5">
          <div
            className="w-9 h-9 rounded-xl flex items-center justify-center font-bold text-sm shadow-md"
            style={{
              backgroundColor: `${palette.secondary}25`,
              color: palette.secondary,
              border: `1px solid ${palette.secondary}50`,
            }}
          >
            <BookOpen className="w-4 h-4" />
          </div>
          <div>
            <h1
              className="font-bold text-sm tracking-tight"
              style={{ color: palette.textPrimary }}
            >
              Preserved Memories
            </h1>
            <p className="text-[11px]" style={{ color: palette.textSecondary }}>
              {profile.lovedOneName}'s Stories & Values ({memories.length})
            </p>
          </div>
        </div>

        <button
          onClick={() => {
            setMemoryToEdit(null);
            setIsAddOpen(true);
          }}
          className="px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 shadow-md active:scale-95 transition-transform"
          style={{
            backgroundColor: palette.primary,
            color: '#ffffff',
          }}
        >
          <Plus className="w-4 h-4" />
          <span>Preserve</span>
        </button>
      </header>

      {/* Filter & Search Bar */}
      <div className="p-4 pb-2 space-y-3 shrink-0">
        {/* Search */}
        <div
          className="flex items-center gap-2 px-3.5 py-2 rounded-xl border"
          style={{
            backgroundColor: palette.card,
            borderColor: palette.border,
          }}
        >
          <Search className="w-4 h-4" style={{ color: palette.textMuted }} />
          <input
            type="text"
            placeholder="Search stories, topics, recipes, tags..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-transparent text-sm outline-none"
            style={{ color: palette.textPrimary }}
          />
        </div>

        {/* Category Pills */}
        <div className="flex gap-1.5 overflow-x-auto no-scrollbar pb-1">
          <button
            onClick={() => setSelectedCategory('all')}
            className="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors"
            style={{
              backgroundColor:
                selectedCategory === 'all'
                  ? palette.primary
                  : `${palette.border}70`,
              color: selectedCategory === 'all' ? '#ffffff' : palette.textPrimary,
            }}
          >
            All ({memories.length})
          </button>
          {(Object.keys(CATEGORY_CONFIG) as MemoryCategoryType[]).map((catKey) => {
            const conf = CATEGORY_CONFIG[catKey];
            const isSelected = selectedCategory === catKey;
            const count = memories.filter((m) => m.category === catKey).length;
            return (
              <button
                key={catKey}
                onClick={() => setSelectedCategory(catKey)}
                className="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors"
                style={{
                  backgroundColor: isSelected ? conf.color : `${palette.border}70`,
                  color: isSelected ? '#ffffff' : palette.textPrimary,
                }}
              >
                {conf.label} ({count})
              </button>
            );
          })}
        </div>
      </div>

      {/* Memories Cards List */}
      <div className="flex-1 overflow-y-auto px-4 py-2">
        {filteredMemories.length === 0 ? (
          <div className="py-16 text-center text-sm space-y-2" style={{ color: palette.textMuted }}>
            <BookOpen className="w-10 h-10 mx-auto opacity-40 mb-2" />
            <p>No preserved memories found matching this query.</p>
            <button
              onClick={() => {
                setSearch('');
                setSelectedCategory('all');
              }}
              className="text-xs font-semibold underline"
              style={{ color: palette.primary }}
            >
              Reset filters
            </button>
          </div>
        ) : (
          <div className="max-w-4xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-3 pb-6">
            {filteredMemories.map((mem) => {
              const catConf = CATEGORY_CONFIG[mem.category] || CATEGORY_CONFIG.personal;
              return (
                <div
                  key={mem.id}
                  onClick={() => setSelectedMemoryForDetail(mem)}
                  className="p-4 rounded-2xl border text-left cursor-pointer transition-all hover:translate-y-[-1px] active:scale-[0.99] shadow-sm flex flex-col justify-between"
                  style={{
                    backgroundColor: palette.card,
                    borderColor: palette.border,
                  }}
                >
                  <div>
                    {/* Top Row: Category & Emotion */}
                    <div className="flex items-center justify-between mb-2">
                      <span
                        className="text-[11px] font-semibold px-2 py-0.5 rounded-md"
                        style={{
                          backgroundColor: catConf.bgLight,
                          color: catConf.color,
                        }}
                      >
                        {catConf.label}
                      </span>
                      {mem.emotionTag && (
                        <span className="text-[11px] font-medium" style={{ color: palette.textSecondary }}>
                          {mem.emotionTag}
                        </span>
                      )}
                    </div>

                    {/* Title */}
                    <h3
                      className="font-bold text-sm tracking-tight mb-1.5"
                      style={{ color: palette.textPrimary }}
                    >
                      {mem.title}
                    </h3>

                    {/* Excerpt */}
                    <p
                      className="text-xs leading-relaxed line-clamp-3 mb-3"
                      style={{ color: palette.textSecondary }}
                    >
                      {mem.content}
                    </p>
                  </div>

                  {/* Footer: Date & Tags */}
                  <div className="pt-2 border-t flex items-center justify-between text-[11px]" style={{ borderColor: `${palette.border}60` }}>
                    <div className="flex items-center gap-1" style={{ color: palette.textMuted }}>
                      <Calendar className="w-3 h-3" />
                      <span>{mem.memoryDate || 'Undated'}</span>
                    </div>

                    <div className="flex items-center gap-1 overflow-hidden">
                      {mem.tags.slice(0, 2).map((t, idx) => (
                        <span
                          key={idx}
                          className="px-1.5 py-0.5 rounded text-[10px] truncate max-w-[80px]"
                          style={{
                            backgroundColor: `${palette.border}90`,
                            color: palette.textMuted,
                          }}
                        >
                          #{t}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Detail Modal */}
      <MemoryDetailModal
        memory={selectedMemoryForDetail}
        isOpen={selectedMemoryForDetail !== null}
        onClose={() => setSelectedMemoryForDetail(null)}
        onEdit={(mem) => {
          setSelectedMemoryForDetail(null);
          setMemoryToEdit(mem);
          setIsAddOpen(true);
        }}
        onReflectInChat={(prompt) => {
          setSelectedMemoryForDetail(null);
          onReflectInChat(prompt);
        }}
      />

      {/* Add / Edit Modal */}
      <AddEditMemoryModal
        isOpen={isAddOpen}
        onClose={() => {
          setIsAddOpen(false);
          setMemoryToEdit(null);
        }}
        memoryToEdit={memoryToEdit}
      />
    </div>
  );
};
