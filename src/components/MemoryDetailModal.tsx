import React from 'react';
import { X, Calendar, Edit3, Trash2, MessageSquare, Tag } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { Memory } from '../types';
import { CATEGORY_CONFIG } from '../constants/theme';

interface MemoryDetailModalProps {
  memory: Memory | null;
  isOpen: boolean;
  onClose: () => void;
  onEdit: (mem: Memory) => void;
  onReflectInChat: (title: string) => void;
}

export const MemoryDetailModal: React.FC<MemoryDetailModalProps> = ({
  memory,
  isOpen,
  onClose,
  onEdit,
  onReflectInChat,
}) => {
  const { palette, deleteMemory } = useApp();

  if (!isOpen || !memory) return null;

  const catConfig = CATEGORY_CONFIG[memory.category] || CATEGORY_CONFIG.personal;

  const handleDelete = () => {
    if (window.confirm(`Are you sure you want to delete "${memory.title}"?`)) {
      deleteMemory(memory.id);
      onClose();
    }
  };

  return (
    <div
      id="memory-detail-modal"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-lg max-h-[85vh] flex flex-col rounded-t-3xl sm:rounded-3xl shadow-2xl border overflow-hidden"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        {/* Header */}
        <div
          className="p-5 pb-3 border-b flex items-start justify-between"
          style={{ borderColor: palette.border }}
        >
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span
                className="px-2.5 py-0.5 rounded-full text-xs font-semibold"
                style={{
                  backgroundColor: catConfig.bgLight,
                  color: catConfig.color,
                }}
              >
                {catConfig.label}
              </span>
              {memory.emotionTag && (
                <span className="text-xs px-2 py-0.5 rounded-full bg-black/5 dark:bg-white/10 font-medium">
                  {memory.emotionTag}
                </span>
              )}
            </div>
            <h2
              className="text-lg font-bold tracking-tight"
              style={{ color: palette.textPrimary }}
            >
              {memory.title}
            </h2>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {memory.memoryDate && (
            <div
              className="flex items-center gap-1.5 text-xs font-medium"
              style={{ color: palette.textMuted }}
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>Occurred around {memory.memoryDate}</span>
            </div>
          )}

          <div
            className="p-4 rounded-2xl border leading-relaxed text-sm whitespace-pre-wrap"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
              color: palette.textPrimary,
            }}
          >
            {memory.content}
          </div>

          {/* Tags */}
          {memory.tags.length > 0 && (
            <div>
              <div
                className="text-xs font-semibold mb-1.5 flex items-center gap-1"
                style={{ color: palette.textSecondary }}
              >
                <Tag className="w-3.5 h-3.5" />
                <span>Associated Tags</span>
              </div>
              <div className="flex flex-wrap gap-1.5">
                {memory.tags.map((tag, i) => (
                  <span
                    key={i}
                    className="px-2.5 py-1 rounded-lg text-xs font-medium border"
                    style={{
                      backgroundColor: palette.card,
                      borderColor: palette.border,
                      color: palette.textSecondary,
                    }}
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Actions Footer */}
        <div
          className="p-4 border-t flex items-center justify-between gap-2"
          style={{ borderColor: palette.border }}
        >
          <div className="flex items-center gap-2">
            <button
              onClick={() => {
                onEdit(memory);
                onClose();
              }}
              className="px-3 py-2 rounded-xl text-xs font-medium border flex items-center gap-1.5 hover:opacity-80 transition-colors"
              style={{
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            >
              <Edit3 className="w-3.5 h-3.5" />
              <span>Edit</span>
            </button>
            <button
              onClick={handleDelete}
              className="px-3 py-2 rounded-xl text-xs font-medium border border-red-500/30 text-red-400 hover:bg-red-500/10 flex items-center gap-1.5 transition-colors"
            >
              <Trash2 className="w-3.5 h-3.5" />
              <span>Delete</span>
            </button>
          </div>

          <button
            onClick={() => {
              onReflectInChat(`Appa, "${memory.title}" pathi pesalama?`);
              onClose();
            }}
            className="px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-1.5 shadow-md active:scale-95 transition-transform"
            style={{
              backgroundColor: palette.primary,
              color: '#ffffff',
            }}
          >
            <MessageSquare className="w-3.5 h-3.5" />
            <span>Reflect in Chat</span>
          </button>
        </div>
      </div>
    </div>
  );
};
