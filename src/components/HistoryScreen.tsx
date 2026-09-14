import React, { useState } from 'react';
import { History, Plus, Search, MessageSquare, Edit2, Trash2, ArrowRight } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { ConversationSession } from '../types';
import { RenameSessionModal } from './RenameSessionModal';

interface HistoryScreenProps {
  onSwitchToChat: () => void;
}

export const HistoryScreen: React.FC<HistoryScreenProps> = ({ onSwitchToChat }) => {
  const { palette, sessions, loadSession, deleteSession, startNewSession } = useApp();
  const [search, setSearch] = useState('');
  const [renamingSession, setRenamingSession] = useState<ConversationSession | null>(null);

  const filteredSessions = sessions.filter((s) => {
    return (
      !search.trim() ||
      s.title.toLowerCase().includes(search.toLowerCase()) ||
      s.summaryPreview.toLowerCase().includes(search.toLowerCase())
    );
  });

  const handleOpenSession = (sessionId: string) => {
    loadSession(sessionId);
    onSwitchToChat();
  };

  const handleDelete = (session: ConversationSession) => {
    if (window.confirm(`Delete conversation "${session.title}"? This cannot be undone.`)) {
      deleteSession(session.id);
    }
  };

  return (
    <div
      id="history-screen"
      className="flex flex-col h-full overflow-hidden select-none"
      style={{ backgroundColor: palette.background }}
    >
      {/* Header */}
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
              backgroundColor: `${palette.primary}25`,
              color: palette.primary,
              border: `1px solid ${palette.primary}50`,
            }}
          >
            <History className="w-4 h-4" />
          </div>
          <div>
            <h1
              className="font-bold text-sm tracking-tight"
              style={{ color: palette.textPrimary }}
            >
              Conversation History
            </h1>
            <p className="text-[11px]" style={{ color: palette.textSecondary }}>
              Past Reflections ({sessions.length})
            </p>
          </div>
        </div>

        <button
          onClick={() => {
            startNewSession();
            onSwitchToChat();
          }}
          className="px-3 py-1.5 rounded-xl text-xs font-semibold flex items-center gap-1.5 shadow-md active:scale-95 transition-transform"
          style={{
            backgroundColor: palette.primary,
            color: '#ffffff',
          }}
        >
          <Plus className="w-4 h-4" />
          <span>New</span>
        </button>
      </header>

      {/* Search Bar */}
      <div className="p-4 pb-2 shrink-0">
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
            placeholder="Search past conversations..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-transparent text-sm outline-none"
            style={{ color: palette.textPrimary }}
          />
        </div>
      </div>

      {/* Sessions List */}
      <div className="flex-1 overflow-y-auto px-4 py-2">
        {filteredSessions.length === 0 ? (
          <div className="py-16 text-center text-sm space-y-2" style={{ color: palette.textMuted }}>
            <MessageSquare className="w-10 h-10 mx-auto opacity-40 mb-2" />
            <p>No conversation sessions found.</p>
            <button
              onClick={() => {
                startNewSession();
                onSwitchToChat();
              }}
              className="text-xs font-semibold underline"
              style={{ color: palette.primary }}
            >
              Start a new conversation now
            </button>
          </div>
        ) : (
          <div className="max-w-3xl mx-auto space-y-2.5 pb-6">
            {filteredSessions.map((session) => (
              <div
                key={session.id}
                className="p-4 rounded-2xl border transition-all hover:scale-[1.005] active:scale-[0.99] shadow-sm flex flex-col justify-between gap-2"
                style={{
                  backgroundColor: palette.card,
                  borderColor: palette.border,
                }}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 cursor-pointer" onClick={() => handleOpenSession(session.id)}>
                    <div className="flex items-center gap-2 mb-1">
                      <h3
                        className="font-bold text-sm tracking-tight"
                        style={{ color: palette.textPrimary }}
                      >
                        {session.title}
                      </h3>
                      <span
                        className="text-[10px] px-1.5 py-0.5 rounded-md font-semibold"
                        style={{
                          backgroundColor: `${palette.primary}18`,
                          color: palette.primary,
                        }}
                      >
                        {session.messages.length} msgs
                      </span>
                    </div>

                    <p
                      className="text-xs leading-relaxed line-clamp-2"
                      style={{ color: palette.textSecondary }}
                    >
                      {session.summaryPreview || 'Empty reflection'}
                    </p>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      onClick={() => setRenamingSession(session)}
                      title="Rename Conversation"
                      className="p-1.5 rounded-lg hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
                      style={{ color: palette.textSecondary }}
                    >
                      <Edit2 className="w-3.5 h-3.5" />
                    </button>
                    <button
                      onClick={() => handleDelete(session)}
                      title="Delete Conversation"
                      className="p-1.5 rounded-lg hover:bg-red-500/10 text-red-400 transition-colors"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                <div className="pt-2 border-t flex items-center justify-between text-[11px]" style={{ borderColor: `${palette.border}60` }}>
                  <span style={{ color: palette.textMuted }}>
                    {new Date(session.startedAt).toLocaleDateString(undefined, {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </span>

                  <button
                    onClick={() => handleOpenSession(session.id)}
                    className="flex items-center gap-1 font-semibold text-xs hover:underline"
                    style={{ color: palette.primary }}
                  >
                    <span>Resume Reflection</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Rename Modal */}
      {renamingSession && (
        <RenameSessionModal
          isOpen={true}
          sessionId={renamingSession.id}
          currentTitle={renamingSession.title}
          onClose={() => setRenamingSession(null)}
        />
      )}
    </div>
  );
};
