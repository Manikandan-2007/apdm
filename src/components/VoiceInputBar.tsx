import React, { useState, useRef, useEffect } from 'react';
import { Mic, Send, Plus } from 'lucide-react';
import { useApp } from '../context/AppContext';

interface VoiceInputBarProps {
  onSendMessage: (text: string) => void;
  onMicTap: () => void;
  onPlusTap: () => void;
  isVoiceActive?: boolean;
}

export const VoiceInputBar: React.FC<VoiceInputBarProps> = ({
  onSendMessage,
  onMicTap,
  onPlusTap,
  isVoiceActive = false,
}) => {
  const { palette } = useApp();
  const [text, setText] = useState('');
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleSend = () => {
    if (!text.trim()) return;
    onSendMessage(text.trim());
    setText('');
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  // Auto-resize textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = `${Math.min(
        textareaRef.current.scrollHeight,
        120
      )}px`;
    }
  }, [text]);

  const hasText = text.trim().length > 0;

  return (
    <div
      id="voice-input-bar"
      className="p-3 border-t transition-colors duration-200"
      style={{
        backgroundColor: palette.surface,
        borderColor: palette.border,
      }}
    >
      <div className="flex items-end gap-2 max-w-4xl mx-auto">
        {/* Quick actions "+" button */}
        <button
          id="btn-quick-actions"
          type="button"
          onClick={onPlusTap}
          aria-label="Add memory or open actions"
          className="flex-shrink-0 w-11 h-11 rounded-full flex items-center justify-center transition-transform active:scale-95 hover:opacity-90"
          style={{
            backgroundColor: `${palette.primary}18`,
            color: palette.primary,
            border: `1px solid ${palette.primary}30`,
          }}
        >
          <Plus className="w-5 h-5" />
        </button>

        {/* Input box */}
        <div
          className="flex-1 rounded-2xl px-4 py-2 flex items-center min-h-[44px] border transition-colors"
          style={{
            backgroundColor: palette.card,
            borderColor: palette.border,
          }}
        >
          <textarea
            id="chat-textarea"
            ref={textareaRef}
            rows={1}
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type here..."
            className="w-full bg-transparent resize-none outline-none text-sm leading-relaxed"
            style={{
              color: palette.textPrimary,
            }}
          />
        </div>

        {/* Right action button: Send if text, or Mic if empty */}
        {hasText ? (
          <button
            id="btn-send-message"
            type="button"
            onClick={handleSend}
            aria-label="Send message"
            className="flex-shrink-0 w-11 h-11 rounded-full flex items-center justify-center transition-transform active:scale-95 shadow-md"
            style={{
              backgroundColor: palette.primary,
              color: '#ffffff',
            }}
          >
            <Send className="w-5 h-5" />
          </button>
        ) : (
          <button
            id="btn-voice-toggle"
            type="button"
            onClick={onMicTap}
            aria-label="Start voice input"
            className={`flex-shrink-0 w-11 h-11 rounded-full flex items-center justify-center transition-all active:scale-95 shadow-md ${
              isVoiceActive ? 'animate-pulse ring-4 ring-sky-400/40' : ''
            }`}
            style={{
              backgroundColor: isVoiceActive ? '#48CAE4' : palette.primary,
              color: '#ffffff',
            }}
          >
            <Mic className="w-5 h-5" />
          </button>
        )}
      </div>
    </div>
  );
};
