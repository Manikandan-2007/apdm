import React, { useState, useEffect } from 'react';
import { X, Save, Calendar, Tag, Smile } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { Memory, MemoryCategoryType } from '../types';
import { CATEGORY_CONFIG } from '../constants/theme';

interface AddEditMemoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  memoryToEdit?: Memory | null;
}

const EMOTIONS = [
  'Heartwarming 🏡',
  'Sentimental ❤️',
  'Inspiring 🌟',
  'Peaceful 🕊️',
  'Cherished 🌸',
  'Emotional 💛',
];

export const AddEditMemoryModal: React.FC<AddEditMemoryModalProps> = ({
  isOpen,
  onClose,
  memoryToEdit,
}) => {
  const { palette, addMemory, updateMemory } = useApp();

  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [category, setCategory] = useState<MemoryCategoryType>('personal');
  const [memoryDate, setMemoryDate] = useState('');
  const [emotionTag, setEmotionTag] = useState('Heartwarming 🏡');
  const [tagsInput, setTagsInput] = useState('');

  useEffect(() => {
    if (memoryToEdit) {
      setTitle(memoryToEdit.title);
      setContent(memoryToEdit.content);
      setCategory(memoryToEdit.category);
      setMemoryDate(memoryToEdit.memoryDate || '');
      setEmotionTag(memoryToEdit.emotionTag || 'Heartwarming 🏡');
      setTagsInput(memoryToEdit.tags.join(', '));
    } else {
      setTitle('');
      setContent('');
      setCategory('family');
      setMemoryDate(new Date().toISOString().split('T')[0]);
      setEmotionTag('Heartwarming 🏡');
      setTagsInput('');
    }
  }, [memoryToEdit, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !content.trim()) return;

    const tags = tagsInput
      .split(',')
      .map((t) => t.trim())
      .filter((t) => t.length > 0);

    if (memoryToEdit) {
      updateMemory({
        ...memoryToEdit,
        title: title.trim(),
        content: content.trim(),
        category,
        memoryDate: memoryDate || undefined,
        emotionTag,
        tags,
      });
    } else {
      addMemory({
        title: title.trim(),
        content: content.trim(),
        category,
        memoryDate: memoryDate || undefined,
        emotionTag,
        tags,
      });
    }

    onClose();
  };

  return (
    <div
      id="add-edit-memory-modal"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-lg max-h-[90vh] flex flex-col rounded-t-3xl sm:rounded-3xl shadow-2xl border overflow-hidden"
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
          <h2
            className="text-lg font-bold tracking-tight"
            style={{ color: palette.textPrimary }}
          >
            {memoryToEdit ? 'Edit Preserved Memory' : 'Preserve a New Memory'}
          </h2>
          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* Category Selector */}
          <div>
            <label
              className="block text-xs font-semibold mb-2"
              style={{ color: palette.textSecondary }}
            >
              Category
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
              {(Object.keys(CATEGORY_CONFIG) as MemoryCategoryType[]).map((catKey) => {
                const conf = CATEGORY_CONFIG[catKey];
                const isSelected = category === catKey;
                return (
                  <button
                    key={catKey}
                    type="button"
                    onClick={() => setCategory(catKey)}
                    className="p-2.5 rounded-xl border text-xs font-medium transition-all text-center"
                    style={{
                      backgroundColor: isSelected ? conf.color : palette.card,
                      color: isSelected ? '#ffffff' : palette.textPrimary,
                      borderColor: isSelected ? conf.color : palette.border,
                    }}
                  >
                    {conf.label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Title */}
          <div>
            <label
              className="block text-xs font-semibold mb-1"
              style={{ color: palette.textSecondary }}
            >
              Memory Title *
            </label>
            <input
              type="text"
              required
              placeholder="e.g., Sunday Kaapi & Sambar with Appa"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl border text-sm outline-none transition-colors"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            />
          </div>

          {/* Content / Story */}
          <div>
            <label
              className="block text-xs font-semibold mb-1"
              style={{ color: palette.textSecondary }}
            >
              The Story / Memory Content *
            </label>
            <textarea
              required
              rows={4}
              placeholder="Describe what happened, what was spoken, the emotions, sounds, or values shared..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl border text-sm outline-none resize-none leading-relaxed transition-colors"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            />
          </div>

          {/* Date & Emotion Row */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label
                className="block text-xs font-semibold mb-1 flex items-center gap-1.5"
                style={{ color: palette.textSecondary }}
              >
                <Calendar className="w-3.5 h-3.5" />
                <span>Memory Date (Approx)</span>
              </label>
              <input
                type="date"
                value={memoryDate}
                onChange={(e) => setMemoryDate(e.target.value)}
                className="w-full px-3.5 py-2 rounded-xl border text-xs outline-none"
                style={{
                  backgroundColor: palette.card,
                  borderColor: palette.border,
                  color: palette.textPrimary,
                }}
              />
            </div>

            <div>
              <label
                className="block text-xs font-semibold mb-1 flex items-center gap-1.5"
                style={{ color: palette.textSecondary }}
              >
                <Smile className="w-3.5 h-3.5" />
                <span>Emotion / Mood</span>
              </label>
              <select
                value={emotionTag}
                onChange={(e) => setEmotionTag(e.target.value)}
                className="w-full px-3.5 py-2 rounded-xl border text-xs outline-none"
                style={{
                  backgroundColor: palette.card,
                  borderColor: palette.border,
                  color: palette.textPrimary,
                }}
              >
                {EMOTIONS.map((em) => (
                  <option key={em} value={em}>
                    {em}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Tags */}
          <div>
            <label
              className="block text-xs font-semibold mb-1 flex items-center gap-1.5"
              style={{ color: palette.textSecondary }}
            >
              <Tag className="w-3.5 h-3.5" />
              <span>Tags (comma separated)</span>
            </label>
            <input
              type="text"
              placeholder="Meenu, Dinesh, Coffee, Advice, Childhood"
              value={tagsInput}
              onChange={(e) => setTagsInput(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl border text-sm outline-none"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            />
          </div>

          {/* Submit Button */}
          <div className="pt-2">
            <button
              type="submit"
              className="w-full py-3 rounded-xl font-semibold text-sm flex items-center justify-center gap-2 shadow-lg transition-transform active:scale-95"
              style={{
                backgroundColor: palette.primary,
                color: '#ffffff',
              }}
            >
              <Save className="w-4 h-4" />
              <span>{memoryToEdit ? 'Save Changes' : 'Preserve Memory Forever'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
