import React, { useState } from 'react';
import { X, Check } from 'lucide-react';
import { useApp } from '../context/AppContext';

interface RenameSessionModalProps {
  isOpen: boolean;
  onClose: () => void;
  sessionId: string;
  currentTitle: string;
}

export const RenameSessionModal: React.FC<RenameSessionModalProps> = ({
  isOpen,
  onClose,
  sessionId,
  currentTitle,
}) => {
  const { palette, renameSession } = useApp();
  const [title, setTitle] = useState(currentTitle);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    renameSession(sessionId, title.trim());
    onClose();
  };

  return (
    <div
      id="rename-session-modal"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
    >
      <div
        className="w-full max-w-md rounded-2xl shadow-2xl border p-5"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-bold text-base" style={{ color: palette.textPrimary }}>
            Rename Conversation
          </h3>
          <button
            onClick={onClose}
            className="p-1 rounded-full hover:bg-black/10 dark:hover:bg-white/10"
            style={{ color: palette.textSecondary }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold mb-1" style={{ color: palette.textSecondary }}>
              New Title
            </label>
            <input
              type="text"
              required
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full px-3.5 py-2 rounded-xl border text-sm outline-none"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            />
          </div>

          <div className="flex justify-end gap-2 pt-1">
            <button
              type="button"
              onClick={onClose}
              className="px-3.5 py-2 rounded-xl text-xs font-medium border"
              style={{
                borderColor: palette.border,
                color: palette.textSecondary,
              }}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-1.5 shadow-md"
              style={{
                backgroundColor: palette.primary,
                color: '#ffffff',
              }}
            >
              <Check className="w-3.5 h-3.5" />
              <span>Save Title</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
