import React, { useState } from 'react';
import {
  X,
  Volume2,
  VolumeX,
  MessageSquare,
  Sparkles,
  ChevronDown,
  ChevronUp,
  Square,
  Globe,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { VoiceOrbVisualizer } from './VoiceOrbVisualizer';
import { speechService } from '../services/speechService';

interface VoiceConversationScreenProps {
  onClose: () => void;
  onNavigateToChat: () => void;
}

export const VoiceConversationScreen: React.FC<VoiceConversationScreenProps> = ({
  onClose,
  onNavigateToChat,
}) => {
  const {
    palette,
    voiceState,
    liveTranscript,
    soundLevel,
    isMuted,
    setIsMuted,
    activeSession,
    activeSpeaker,
    sendMessage,
  } = useApp();

  const [showFullTranscript, setShowFullTranscript] = useState(false);
  const [currentVoiceLang, setCurrentVoiceLang] = useState<string>(
    speechService.getRecognitionLanguage() || 'ta-IN'
  );

  const toggleVoiceLang = () => {
    const next = currentVoiceLang === 'ta-IN' ? 'en-IN' : 'ta-IN';
    speechService.setRecognitionLanguage(next);
    setCurrentVoiceLang(next);
  };

  const messages = activeSession?.messages || [];

  const handleOrbTap = async () => {
    if (voiceState === 'ready') {
      await speechService.startListening();
    } else if (voiceState === 'listening') {
      const transcript = await speechService.stopListening();
      const finalUtterance = transcript.trim() || liveTranscript.trim();
      if (finalUtterance) {
        speechService.setState('processing');
        await sendMessage(finalUtterance);
      } else {
        speechService.setState('ready');
      }
    } else if (voiceState === 'speaking') {
      speechService.stopSpeaking();
    }
  };

  const handlePromptSelect = async (prompt: string) => {
    speechService.stopSpeaking();
    speechService.setState('processing');
    await sendMessage(prompt);
  };

  const quickPrompts =
    activeSpeaker === 'meenu'
      ? [
          'College studies stress-a irukku...',
          'Vendakkai poriyal samayal tips sollu',
          'Enakku konjam dhairiyam venum',
          'Morning filter coffee memories',
        ]
      : activeSpeaker === 'dinesh'
      ? [
          'Business decision-la guidance venum',
          'Work ethics and honesty pathi sollu',
          'Stress handle panna help pannunga',
          'Family responsibility pathi pesalaam',
        ]
      : activeSpeaker === 'padma'
      ? [
          'Morning filter coffee time pathi pesuvoma?',
          'Namma kudumba anbum amaidhiyum',
          'Pillaiyungaloda future pathi konjam pesalaam',
          'Sunday samayal traditions',
        ]
      : [
          'Can you explain AI to me?',
          'Tell me an inspiring family lesson',
          'Morning filter coffee memories',
          'College studies advice',
        ];

  return (
    <div
      id="voice-conversation-screen"
      className="fixed inset-0 z-40 flex flex-col justify-between overflow-hidden select-none transition-colors duration-500"
      style={{
        background: `radial-gradient(circle at 50% 30%, ${palette.surface} 0%, ${palette.background} 100%)`,
      }}
    >
      {/* Top Bar */}
      <header className="px-5 py-4 flex items-center justify-between z-10">
        <div>
          <h2
            className="text-base font-bold tracking-tight"
            style={{ color: palette.textPrimary }}
          >
            APDM Voice Companion
          </h2>
          <p className="text-xs" style={{ color: palette.textSecondary }}>
            {activeSpeaker === 'meenu'
              ? 'Speaking with Meenu'
              : activeSpeaker === 'dinesh'
              ? 'Speaking with Dinesh'
              : activeSpeaker === 'padma'
              ? 'Speaking with Padma'
              : 'Family Conversation'}
          </p>
        </div>

        <div className="flex items-center gap-2">
          {/* Spoken voice language indicator & toggle */}
          <button
            onClick={toggleVoiceLang}
            className="px-2.5 py-1 rounded-full text-xs font-semibold border flex items-center gap-1.5 transition-all active:scale-95 shadow-xs"
            style={{
              backgroundColor: `${palette.primary}18`,
              borderColor: `${palette.primary}40`,
              color: palette.primary,
            }}
            title="Spoken Language (Click to toggle Tamil / English)"
            aria-label="Toggle spoken voice language"
          >
            <Globe className="w-3.5 h-3.5" />
            <span>{currentVoiceLang === 'ta-IN' ? 'Tamil (ta-IN)' : 'English (en-IN)'}</span>
          </button>

          <button
            onClick={() => setIsMuted(!isMuted)}
            className="p-2 rounded-full hover:bg-white/10 transition-colors"
            style={{ color: isMuted ? palette.textMuted : palette.primary }}
          >
            {isMuted ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
          </button>

          <button
            onClick={() => {
              speechService.stopSpeaking();
              speechService.cancelListening();
              onNavigateToChat();
            }}
            className="p-2 rounded-full hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
            title="Open Chat View"
          >
            <MessageSquare className="w-5 h-5" />
          </button>

          <button
            onClick={() => {
              speechService.stopSpeaking();
              speechService.cancelListening();
              onClose();
            }}
            className="p-2 rounded-full hover:bg-white/10 transition-colors"
            style={{ color: palette.textSecondary }}
            title="Exit Voice Mode"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
      </header>

      {/* Center Animated Voice Orb */}
      <div className="flex-1 flex flex-col items-center justify-center px-4">
        <VoiceOrbVisualizer
          state={voiceState}
          soundLevel={soundLevel}
          onTap={handleOrbTap}
          size={240}
        />

        {/* Stop Voice Button during speech output */}
        {voiceState === 'speaking' && (
          <button
            onClick={() => speechService.stopSpeaking()}
            className="mt-4 px-4 py-1.5 rounded-full text-xs font-semibold bg-red-500/20 text-red-300 border border-red-500/40 hover:bg-red-500/30 transition-all flex items-center gap-1.5 active:scale-95 shadow-md"
          >
            <Square className="w-3.5 h-3.5 fill-current" />
            <span>Stop Speaking</span>
          </button>
        )}

        {/* Live Transcript / Feedback */}
        <div className="mt-6 min-h-[60px] max-w-md text-center px-4">
          {voiceState === 'listening' ? (
            <div className="space-y-1 animate-pulse">
              <p className="text-sm font-medium" style={{ color: '#48CAE4' }}>
                {liveTranscript ||
                  (currentVoiceLang === 'ta-IN'
                    ? 'Listening in Tamil (ta-IN)... Speak freely'
                    : 'Listening in English (en-IN)... Speak freely')}
              </p>
              <p className="text-[11px]" style={{ color: palette.textMuted }}>
                Tap the orb when done speaking
              </p>
            </div>
          ) : voiceState === 'processing' ? (
            <div className="flex items-center justify-center gap-2">
              <Sparkles className="w-4 h-4 animate-spin" style={{ color: palette.primary }} />
              <p className="text-sm italic" style={{ color: palette.textSecondary }}>
                Thinking...
              </p>
            </div>
          ) : voiceState === 'speaking' ? (
            <div className="space-y-1">
              <p className="text-sm font-medium" style={{ color: '#E76F51' }}>
                APDM is speaking...
              </p>
              <p className="text-[11px]" style={{ color: palette.textMuted }}>
                Tap Stop Speaking or tap orb to halt
              </p>
            </div>
          ) : (
            <p className="text-xs leading-relaxed" style={{ color: palette.textSecondary }}>
              Tap the orb to speak. APDM understands Tamil, Tanglish, and English.
            </p>
          )}
        </div>
      </div>

      {/* Bottom Area: Quick Prompts & Transcript Expander */}
      <div className="p-4 z-10 max-w-xl mx-auto w-full space-y-3">
        {/* Quick prompt suggestions */}
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {quickPrompts.map((prompt, idx) => (
            <button
              key={idx}
              onClick={() => handlePromptSelect(prompt)}
              className="px-3.5 py-1.5 rounded-full text-xs font-medium whitespace-nowrap border transition-all active:scale-95 shrink-0"
              style={{
                backgroundColor: `${palette.surface}cc`,
                borderColor: palette.border,
                color: palette.textPrimary,
              }}
            >
              {prompt}
            </button>
          ))}
        </div>

        {/* Transcript Toggle Button */}
        <div className="flex justify-center">
          <button
            onClick={() => setShowFullTranscript(!showFullTranscript)}
            className="flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full hover:bg-white/5 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <span>{showFullTranscript ? 'Hide Conversation' : 'Show Conversation'}</span>
            {showFullTranscript ? (
              <ChevronDown className="w-3.5 h-3.5" />
            ) : (
              <ChevronUp className="w-3.5 h-3.5" />
            )}
          </button>
        </div>

        {/* Expanded Transcript Drawer */}
        {showFullTranscript && (
          <div
            className="max-h-48 overflow-y-auto p-3.5 rounded-2xl border space-y-2 text-xs"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            {messages.length === 0 ? (
              <p className="text-center py-2" style={{ color: palette.textMuted }}>
                No spoken exchanges in this conversation yet.
              </p>
            ) : (
              messages.slice(-4).map((m) => (
                <div
                  key={m.id}
                  className={`p-2 rounded-xl ${
                    m.sender === 'user' ? 'text-right' : 'text-left'
                  }`}
                  style={{
                    backgroundColor:
                      m.sender === 'user'
                        ? `${palette.primary}18`
                        : `${palette.surface}`,
                    color: palette.textPrimary,
                  }}
                >
                  <span className="font-bold text-[10px] block mb-0.5 text-muted-foreground">
                    {m.sender === 'user' ? 'You' : 'APDM'}
                  </span>
                  {m.text}
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  );
};
