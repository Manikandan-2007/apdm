import React, { useRef, useEffect, useState } from 'react';
import {
  Volume2,
  VolumeX,
  Plus,
  Trash2,
  Heart,
  BookOpen,
  Sparkles,
  Users,
  Copy,
  Check,
  Square,
  RotateCcw,
  ChevronDown,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { VoiceInputBar } from './VoiceInputBar';
import { SuggestedConversationsBar } from './SuggestedConversationsBar';
import { AddEditMemoryModal } from './AddEditMemoryModal';
import { ProfileModal } from './ProfileModal';
import { InnumPaaruModal } from './InnumPaaruModal';
import { speechService } from '../services/speechService';
import { FAMILY_MEMBERS } from '../services/familyRelationshipService';
import { FamilyMemberId } from '../types';

interface ChatScreenProps {
  onNavigateToMemories: () => void;
  onNavigateToVoice: () => void;
}

export const ChatScreen: React.FC<ChatScreenProps> = ({
  onNavigateToMemories,
  onNavigateToVoice,
}) => {
  const {
    palette,
    profile,
    activeSession,
    startNewSession,
    clearCurrentChat,
    retryLastMessage,
    switchActiveProfile,
    sendMessage,
    isAiThinking,
    isMuted,
    setIsMuted,
    playAudio,
    stopAudio,
    activeAudioMessageId,
    voiceState,
    activeSpeaker,
    testSound,
    isTestingSound,
  } = useApp();

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [isAddMemoryOpen, setIsAddMemoryOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [isQuickActionsOpen, setIsQuickActionsOpen] = useState(false);
  const [isInnumPaaruOpen, setIsInnumPaaruOpen] = useState(false);
  const [isSpeakerMenuOpen, setIsSpeakerMenuOpen] = useState(false);
  const [copiedMessageId, setCopiedMessageId] = useState<string | null>(null);

  const messages = activeSession?.messages || [];

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages.length, isAiThinking]);

  const handleMicTap = () => {
    onNavigateToVoice();
  };

  const handleCopyMessage = async (id: string, text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopiedMessageId(id);
      setTimeout(() => setCopiedMessageId(null), 2000);
    } catch {
      // fallback
    }
  };

  const activeSpeakerName =
    activeSpeaker === 'meenu'
      ? 'Meenu'
      : activeSpeaker === 'dinesh'
      ? 'Dinesh'
      : activeSpeaker === 'padma'
      ? 'Padma'
      : 'Family';

  return (
    <div
      id="main-chat-screen"
      className="flex flex-col h-full overflow-hidden select-none"
      style={{ backgroundColor: palette.background }}
    >
      {/* Top Header - APDM Branding */}
      <header
        className="px-4 py-3 border-b flex items-center justify-between shrink-0 shadow-sm z-10 transition-colors"
        style={{
          backgroundColor: palette.surface,
          borderColor: palette.border,
        }}
      >
        {/* Brand identity */}
        <div className="flex items-center gap-2.5">
          <div
            className="w-9 h-9 rounded-xl flex items-center justify-center font-bold text-sm shadow-md"
            style={{
              backgroundColor: `${palette.primary}25`,
              color: palette.primary,
              border: `1px solid ${palette.primary}50`,
            }}
          >
            <Heart className="w-4 h-4 fill-current" />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <h1
                className="font-bold text-base tracking-tight"
                style={{ color: palette.textPrimary }}
              >
                APDM
              </h1>
              <span
                className="text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded-md"
                style={{
                  backgroundColor: `${palette.primary}20`,
                  color: palette.primary,
                }}
              >
                Companion
              </span>
            </div>
            <p className="text-[11px]" style={{ color: palette.textSecondary }}>
              Family Companion
            </p>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-1.5 relative">
          {/* Active Family Member Indicator & Dropdown */}
          <div className="relative">
            <button
              onClick={() => setIsSpeakerMenuOpen(!isSpeakerMenuOpen)}
              className="px-2.5 py-1 rounded-full text-xs font-medium border flex items-center gap-1.5 transition-colors shadow-xs hover:opacity-90"
              style={{
                backgroundColor: activeSpeaker !== 'unknown' ? `${palette.primary}18` : palette.card,
                borderColor: activeSpeaker !== 'unknown' ? `${palette.primary}50` : palette.border,
                color: activeSpeaker !== 'unknown' ? palette.primary : palette.textSecondary,
              }}
              title="Active Profile (Click to switch)"
            >
              <Users className="w-3.5 h-3.5" />
              <span>Active: {activeSpeakerName}</span>
              <ChevronDown className="w-3 h-3 opacity-60" />
            </button>

            {isSpeakerMenuOpen && (
              <div
                className="absolute right-0 top-full mt-1.5 w-52 rounded-xl shadow-xl border p-1.5 z-30 space-y-1"
                style={{
                  backgroundColor: palette.surface,
                  borderColor: palette.border,
                }}
              >
                <div className="px-2 py-1 text-[11px] font-bold uppercase tracking-wider" style={{ color: palette.textMuted }}>
                  Switch Active Profile
                </div>
                {(['meenu', 'dinesh', 'padma', 'unknown'] as FamilyMemberId[]).map((mId) => {
                  const mInfo = FAMILY_MEMBERS[mId];
                  const isSelected = activeSpeaker === mId;
                  return (
                    <button
                      key={mId}
                      onClick={() => {
                        switchActiveProfile(mId);
                        setIsSpeakerMenuOpen(false);
                      }}
                      className="w-full text-left px-2.5 py-1.5 rounded-lg text-xs flex items-center justify-between transition-colors hover:opacity-90"
                      style={{
                        backgroundColor: isSelected ? `${palette.primary}25` : 'transparent',
                        color: isSelected ? palette.primary : palette.textPrimary,
                      }}
                    >
                      <div>
                        <div className="font-semibold">{mInfo.displayName}</div>
                        <div className="text-[10px]" style={{ color: palette.textSecondary }}>{mInfo.relationship}</div>
                      </div>
                      {isSelected && <span className="text-[11px] font-bold">✓</span>}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* New Chat Button */}
          <button
            onClick={() => startNewSession()}
            title="New Chat"
            aria-label="New Chat"
            className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
            style={{ color: palette.textSecondary }}
          >
            <Plus className="w-5 h-5" />
          </button>

          {/* Clear Chat Button (only if messages exist) */}
          {messages.length > 0 && (
            <button
              onClick={() => {
                if (confirm('Clear messages in this conversation? Preserved memories will not be deleted.')) {
                  clearCurrentChat();
                }
              }}
              title="Clear Chat"
              aria-label="Clear Chat"
              className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
              style={{ color: palette.textSecondary }}
            >
              <Trash2 className="w-4 h-4" />
            </button>
          )}

          {/* Sound Test Button */}
          <button
            onClick={() => {
              if (isMuted) setIsMuted(false);
              testSound();
            }}
            disabled={isTestingSound}
            title="Sound Test - குரல் / ஒலி சோதனை"
            aria-label="Sound Test"
            className="px-2.5 py-1 rounded-full text-xs font-semibold border flex items-center gap-1.5 transition-all shadow-xs hover:opacity-90 active:scale-95 disabled:opacity-50"
            style={{
              backgroundColor: isTestingSound ? `${palette.primary}30` : `${palette.primary}15`,
              borderColor: `${palette.primary}50`,
              color: palette.primary,
            }}
          >
            <Volume2 className={`w-3.5 h-3.5 ${isTestingSound ? 'animate-bounce' : ''}`} />
            <span className="hidden sm:inline">{isTestingSound ? 'Testing Sound...' : 'Sound Test'}</span>
            <span className="sm:hidden">{isTestingSound ? 'Testing...' : 'Test'}</span>
          </button>

          {/* Mute/Unmute Toggle */}
          <button
            onClick={() => {
              if (!isMuted) speechService.stopSpeaking();
              setIsMuted(!isMuted);
            }}
            title={isMuted ? 'Sound is OFF - Tap to Unmute' : 'Sound is ON - Tap to Mute'}
            aria-label={isMuted ? 'Sound is OFF - Tap to Unmute' : 'Sound is ON - Tap to Mute'}
            className="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
            style={{ color: isMuted ? palette.textMuted : palette.primary }}
          >
            {isMuted ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
          </button>

          {/* Profile Switcher & Avatar */}
          <button
            onClick={() => setIsProfileOpen(true)}
            title="Family Profiles"
            aria-label="Family Profiles"
            className="p-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/5 transition-colors flex items-center justify-center ml-0.5"
          >
            <div
              className="w-7 h-7 rounded-full flex items-center justify-center font-bold text-xs border"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
                color: palette.primary,
              }}
            >
              {profile.avatarInitials || 'SU'}
            </div>
          </button>
        </div>
      </header>

      {/* Main Messages View or Empty State */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.length === 0 ? (
          /* Welcoming Empty State */
          <div className="flex flex-col items-center justify-center py-6 px-2 text-center max-w-lg mx-auto">
            {/* Soft Emblem */}
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center shadow-2xl mb-4 border transition-transform duration-500 hover:scale-105"
              style={{
                backgroundColor: `${palette.primary}20`,
                borderColor: `${palette.primary}60`,
                boxShadow: `0 0 35px ${palette.accentGlow}`,
              }}
            >
              <Heart className="w-9 h-9 fill-current" style={{ color: palette.primary }} />
            </div>

            <h2
              className="text-lg font-bold tracking-tight mb-1"
              style={{ color: palette.textPrimary }}
            >
              Cherished Voices & Memories
            </h2>
            <p className="text-xs max-w-sm mb-4 leading-relaxed" style={{ color: palette.textSecondary }}>
              Conversations, wisdom, and memories preserved for Meenu, Dinesh, and Padma in Tamil, Tanglish, or English.
            </p>

            {/* Quick Audio Test Button */}
            <div className="mb-6">
              <button
                onClick={() => {
                  if (isMuted) setIsMuted(false);
                  testSound();
                }}
                disabled={isTestingSound}
                className="px-4 py-2 rounded-full border text-xs font-semibold flex items-center gap-2 transition-all hover:scale-105 active:scale-95 shadow-sm disabled:opacity-50"
                style={{
                  backgroundColor: `${palette.primary}18`,
                  borderColor: `${palette.primary}50`,
                  color: palette.primary,
                }}
              >
                <Volume2 className={`w-4 h-4 ${isTestingSound ? 'animate-bounce' : ''}`} />
                <span>
                  {isTestingSound
                    ? 'Testing Father Voice & Sound...'
                    : '🔊 Test Voice & Audio'}
                </span>
              </button>
            </div>

            {/* Suggestions */}
            <SuggestedConversationsBar onSelectSuggestion={(p) => sendMessage(p)} />
          </div>
        ) : (
          /* Active Chat Messages */
          <div className="max-w-3xl mx-auto space-y-3.5">
            {messages.map((msg) => {
              const isUser = msg.sender === 'user';
              const isAudioPlaying = activeAudioMessageId === msg.id;

              return (
                <div
                  key={msg.id}
                  className={`flex flex-col ${isUser ? 'items-end' : 'items-start'} group`}
                >
                  <div
                    className={`max-w-[85%] sm:max-w-[75%] rounded-2xl px-4 py-3 shadow-sm text-sm leading-relaxed border transition-all ${
                      isUser
                        ? 'rounded-br-sm'
                        : 'rounded-bl-sm'
                    }`}
                    style={{
                      backgroundColor: isUser
                        ? `${palette.primary}22`
                        : msg.isError
                        ? '#EF444418'
                        : palette.card,
                      borderColor: isUser
                        ? `${palette.primary}50`
                        : msg.isError
                        ? '#EF444460'
                        : palette.border,
                      color: msg.isError ? '#FCA5A5' : palette.textPrimary,
                    }}
                  >
                    {/* Header tags for User message if speaker is identified */}
                    {isUser && msg.speakerId && msg.speakerId !== 'unknown' && (
                      <div className="flex items-center gap-1 mb-1 text-[10px] font-semibold opacity-75 justify-end">
                        <span>
                          {msg.speakerId === 'meenu' ? '🌸 Meenu' : msg.speakerId === 'dinesh' ? '💼 Dinesh' : '☕ Padma'}
                        </span>
                      </div>
                    )}

                    {/* Header tags for AI message */}
                    {!isUser && (
                      <div className="flex items-center gap-2 mb-1.5 text-[11px] font-medium flex-wrap">
                        <span
                          className="px-1.5 py-0.5 rounded font-bold uppercase tracking-wider text-[10px]"
                          style={{
                            backgroundColor: msg.isError ? '#EF444430' : `${palette.primary}25`,
                            color: msg.isError ? '#F87171' : palette.primary,
                          }}
                        >
                          {msg.isError
                            ? 'Warning'
                            : msg.detectedLanguage === 'tanglish'
                            ? 'Tanglish'
                            : msg.detectedLanguage === 'tamil'
                            ? 'Tamil'
                            : 'English'}
                        </span>

                        {/* Family member recipient tag */}
                        {msg.speakerId && msg.speakerId !== 'unknown' && !msg.isError && (
                          <span
                            className="px-1.5 py-0.5 rounded text-[10px] font-semibold tracking-wide"
                            style={{
                              backgroundColor: `${palette.primary}20`,
                              color: palette.primary,
                            }}
                          >
                            To: {FAMILY_MEMBERS[msg.speakerId]?.displayName}
                          </span>
                        )}

                        {msg.memoryContextRef && !msg.isError && (
                          <span
                            className="truncate max-w-[150px] text-[10px] px-1.5 py-0.5 rounded"
                            style={{
                              backgroundColor: `${palette.border}80`,
                              color: palette.textSecondary,
                            }}
                          >
                            📖 {msg.memoryContextRef}
                          </span>
                        )}
                      </div>
                    )}

                    {/* Message Content */}
                    <p className="whitespace-pre-wrap">{msg.text}</p>

                    {/* Footer bar for AI speech playback and Copy */}
                    {!isUser && !msg.isError && (
                      <div className="mt-2.5 pt-2 border-t flex items-center justify-between" style={{ borderColor: `${palette.border}60` }}>
                        <span className="text-[10px]" style={{ color: palette.textMuted }}>
                          {new Date(msg.timestamp).toLocaleTimeString([], {
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </span>

                        <div className="flex items-center gap-1">
                          {/* Copy Response Button */}
                          <button
                            onClick={() => handleCopyMessage(msg.id, msg.text)}
                            className="p-1 rounded-md flex items-center gap-1 text-[11px] font-medium hover:opacity-80 transition-opacity"
                            style={{ color: palette.textSecondary }}
                            title="Copy Response"
                            aria-label="Copy Response"
                          >
                            {copiedMessageId === msg.id ? (
                              <>
                                <Check className="w-3.5 h-3.5 text-emerald-500" />
                                <span className="text-[10px] text-emerald-500 font-semibold">Copied</span>
                              </>
                            ) : (
                              <>
                                <Copy className="w-3.5 h-3.5" />
                                <span className="text-[10px]">Copy</span>
                              </>
                            )}
                          </button>

                          {/* Voice playback / Stop Button */}
                          <button
                            onClick={() => {
                              if (isAudioPlaying) {
                                stopAudio();
                              } else {
                                if (isMuted) setIsMuted(false);
                                playAudio(msg.id, msg.text, msg.detectedLanguage);
                              }
                            }}
                            className="p-1 px-2 rounded-md flex items-center gap-1.5 text-[11px] font-medium hover:opacity-80 transition-all"
                            style={{
                              color: isAudioPlaying ? '#EF4444' : palette.primary,
                              backgroundColor: isAudioPlaying ? '#EF444420' : `${palette.primary}15`,
                              border: `1px solid ${isAudioPlaying ? '#EF444450' : `${palette.primary}35`}`,
                            }}
                            title={isAudioPlaying ? 'Stop Voice' : 'Listen with Audio'}
                            aria-label={isAudioPlaying ? 'Stop Voice' : 'Listen with Audio'}
                          >
                            {isAudioPlaying ? (
                              <>
                                <Square className="w-3.5 h-3.5 fill-current animate-pulse" />
                                <span className="font-bold">Stop</span>
                              </>
                            ) : (
                              <>
                                <Volume2 className="w-3.5 h-3.5" />
                                <span className="font-semibold">Listen</span>
                              </>
                            )}
                          </button>
                        </div>
                      </div>
                    )}

                    {/* Retry Button on Error */}
                    {msg.isError && (
                      <div className="mt-2.5 pt-2 border-t flex items-center justify-between" style={{ borderColor: '#EF444440' }}>
                        <span className="text-[10px] text-red-400 font-medium">Connection issue</span>
                        <button
                          onClick={() => retryLastMessage()}
                          disabled={isAiThinking}
                          className="px-2.5 py-1 rounded-md text-xs font-semibold flex items-center gap-1 bg-red-500/20 text-red-300 hover:bg-red-500/30 transition-colors"
                          title="Retry last message"
                        >
                          <RotateCcw className="w-3.5 h-3.5" />
                          <span>Retry</span>
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}

            {/* Thinking Indicator */}
            {isAiThinking && (
              <div className="flex items-center gap-2 px-3 py-2 rounded-2xl border max-w-fit shadow-sm animate-pulse"
                style={{
                  backgroundColor: palette.card,
                  borderColor: palette.border,
                }}
              >
                <Sparkles className="w-4 h-4 animate-spin" style={{ color: palette.primary }} />
                <span className="text-xs italic" style={{ color: palette.textSecondary }}>
                  Thinking...
                </span>
              </div>
            )}

            <div ref={messagesEndRef} />
          </div>
        )}
      </div>

      {/* Voice / Text Input Bar */}
      <VoiceInputBar
        onSendMessage={sendMessage}
        onMicTap={handleMicTap}
        onPlusTap={() => setIsQuickActionsOpen(true)}
        isVoiceActive={voiceState === 'listening'}
      />

      {/* Quick Actions Bottom Sheet Modal */}
      {isQuickActionsOpen && (
        <div
          id="quick-actions-sheet"
          className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/70 backdrop-blur-sm"
          onClick={() => setIsQuickActionsOpen(false)}
        >
          <div
            className="w-full max-w-sm rounded-t-3xl sm:rounded-3xl border p-5 space-y-3"
            style={{
              backgroundColor: palette.surface,
              borderColor: palette.border,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-10 h-1 rounded-full mx-auto mb-2" style={{ backgroundColor: palette.border }} />

            <h3 className="font-bold text-sm" style={{ color: palette.textPrimary }}>
              Quick Actions
            </h3>

            <button
              onClick={() => {
                setIsQuickActionsOpen(false);
                setIsAddMemoryOpen(true);
              }}
              className="w-full p-3 rounded-2xl border flex items-center gap-3 text-left hover:scale-[1.01] active:scale-[0.99] transition-transform"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
              }}
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${palette.primary}20`, color: palette.primary }}
              >
                <Heart className="w-5 h-5" />
              </div>
              <div>
                <div className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                  Preserve a Memory
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  Add a story, quote, or life lesson
                </div>
              </div>
            </button>

            <button
              onClick={() => {
                setIsQuickActionsOpen(false);
                onNavigateToMemories();
              }}
              className="w-full p-3 rounded-2xl border flex items-center gap-3 text-left hover:scale-[1.01] active:scale-[0.99] transition-transform"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
              }}
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${palette.secondary}20`, color: palette.secondary }}
              >
                <BookOpen className="w-5 h-5" />
              </div>
              <div>
                <div className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                  Browse Preserved Memories
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  View family archive and stories
                </div>
              </div>
            </button>

            <button
              onClick={() => {
                setIsQuickActionsOpen(false);
                setIsInnumPaaruOpen(true);
              }}
              className="w-full p-3 rounded-2xl border flex items-center gap-3 text-left hover:scale-[1.01] active:scale-[0.99] transition-transform"
              style={{
                backgroundColor: palette.card,
                borderColor: palette.border,
              }}
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${palette.primary}20`, color: palette.primary }}
              >
                <Sparkles className="w-5 h-5" />
              </div>
              <div>
                <div className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                  Conversation Starters (80+)
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  Topics for Meenu, Dinesh, Padma, and family
                </div>
              </div>
            </button>
          </div>
        </div>
      )}

      {/* Modals */}
      <AddEditMemoryModal
        isOpen={isAddMemoryOpen}
        onClose={() => setIsAddMemoryOpen(false)}
      />

      <ProfileModal
        isOpen={isProfileOpen}
        onClose={() => setIsProfileOpen(false)}
      />

      <InnumPaaruModal
        isOpen={isInnumPaaruOpen}
        onClose={() => setIsInnumPaaruOpen(false)}
        onSelectPrompt={(p) => sendMessage(p)}
      />
    </div>
  );
};
