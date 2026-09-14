import React, { useState } from 'react';
import {
  Sliders,
  Palette,
  Globe,
  Bot,
  Volume2,
  Heart,
  ShieldAlert,
  Info,
  Key,
  CheckCircle,
  Database,
  Sparkles,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { ThemeSelectorModal } from './ThemeSelectorModal';
import { ProfileModal } from './ProfileModal';

export const SettingsScreen: React.FC = () => {
  const {
    palette,
    profile,
    themePreset,
    languageMode,
    setLanguageMode,
    geminiApiKey,
    setGeminiApiKey,
    geminiModel,
    setGeminiModel,
    isMuted,
    setIsMuted,
    memories,
    sessions,
    activeSpeaker,
    testSound,
    isTestingSound,
  } = useApp();

  const [isThemeOpen, setIsThemeOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [isAboutOpen, setIsAboutOpen] = useState(false);
  const [apiKeyInput, setApiKeyInput] = useState(geminiApiKey);
  const [isKeySaved, setIsKeySaved] = useState(false);

  const handleSaveApiKey = (e: React.FormEvent) => {
    e.preventDefault();
    setGeminiApiKey(apiKeyInput.trim());
    setIsKeySaved(true);
    setTimeout(() => setIsKeySaved(false), 2500);
  };

  return (
    <div
      id="settings-screen"
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
            <Sliders className="w-4 h-4" />
          </div>
          <div>
            <h1
              className="font-bold text-sm tracking-tight"
              style={{ color: palette.textPrimary }}
            >
              Settings & Preferences
            </h1>
            <p className="text-[11px]" style={{ color: palette.textSecondary }}>
              Configuration & Ambience
            </p>
          </div>
        </div>

        <button
          onClick={() => setIsAboutOpen(true)}
          className="p-2 rounded-full hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
          style={{ color: palette.textSecondary }}
          title="About APDM"
        >
          <Info className="w-5 h-5" />
        </button>
      </header>

      {/* Main Settings List */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="max-w-2xl mx-auto space-y-4 pb-8">
          {/* Family Profiles Banner */}
          <div
            onClick={() => setIsProfileOpen(true)}
            className="p-4 rounded-2xl border flex items-center justify-between cursor-pointer hover:scale-[1.01] active:scale-[0.99] transition-transform shadow-sm"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center font-bold text-base shadow-sm border"
                style={{
                  backgroundColor: `${palette.primary}20`,
                  borderColor: palette.primary,
                  color: palette.primary,
                }}
              >
                {profile.avatarInitials || 'SU'}
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-bold text-sm" style={{ color: palette.textPrimary }}>
                    APDM Companion
                  </h3>
                  <span
                    className="text-[10px] px-1.5 py-0.5 rounded-full font-semibold"
                    style={{
                      backgroundColor: `${palette.primary}18`,
                      color: palette.primary,
                    }}
                  >
                    Active: {activeSpeaker === 'meenu' ? 'Meenu' : activeSpeaker === 'dinesh' ? 'Dinesh' : activeSpeaker === 'padma' ? 'Padma' : 'Family'}
                  </span>
                </div>
                <p className="text-xs" style={{ color: palette.textSecondary }}>
                  Family Profiles & Settings (Meenu, Dinesh, Padma)
                </p>
              </div>
            </div>

            <span className="text-xs font-semibold underline ml-2" style={{ color: palette.primary }}>
              Manage →
            </span>
          </div>

          {/* Ambience & Theme */}
          <div
            className="p-4 rounded-2xl border space-y-3"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Palette className="w-4 h-4" style={{ color: palette.primary }} />
                <span className="text-xs font-bold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
                  Appearance & Colors
                </span>
              </div>
              <button
                onClick={() => setIsThemeOpen(true)}
                className="text-xs font-semibold underline"
                style={{ color: palette.primary }}
              >
                Change Preset
              </button>
            </div>

            <div
              onClick={() => setIsThemeOpen(true)}
              className="p-3 rounded-xl border flex items-center justify-between cursor-pointer hover:opacity-90"
              style={{
                backgroundColor: palette.surface,
                borderColor: palette.border,
              }}
            >
              <div>
                <div className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                  {palette.englishName} ({palette.tamilName})
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  {palette.description}
                </div>
              </div>

              <div className="flex items-center -space-x-1">
                <div className="w-4 h-4 rounded-full border border-black/20" style={{ backgroundColor: palette.primary }} />
                <div className="w-4 h-4 rounded-full border border-black/20" style={{ backgroundColor: palette.secondary }} />
                <div className="w-4 h-4 rounded-full border border-black/20" style={{ backgroundColor: palette.background }} />
              </div>
            </div>
          </div>

          {/* Language Mode Selector */}
          <div
            className="p-4 rounded-2xl border space-y-3"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center gap-2.5">
              <Globe className="w-4 h-4" style={{ color: palette.primary }} />
              <span className="text-xs font-bold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
                Language Engine Mode
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
              {[
                {
                  id: 'auto',
                  title: 'Bilingual Auto-Detect',
                  sub: 'Detects Tamil, Tanglish & English dynamically',
                },
                {
                  id: 'tanglish',
                  title: 'Tanglish Natural',
                  sub: 'Spoken colloquial Tamil in English alphabet',
                },
                {
                  id: 'tamil',
                  title: 'Tamil Script',
                  sub: 'Tamil Unicode script responses',
                },
                {
                  id: 'english',
                  title: 'English Pure',
                  sub: 'Empathetic English phrasing',
                },
              ].map((mode) => {
                const isSelected = languageMode === mode.id;
                return (
                  <button
                    key={mode.id}
                    onClick={() => setLanguageMode(mode.id as any)}
                    className="p-3 rounded-xl border text-left transition-all active:scale-95"
                    style={{
                      backgroundColor: isSelected ? `${palette.primary}15` : palette.surface,
                      borderColor: isSelected ? palette.primary : palette.border,
                    }}
                  >
                    <div className="font-semibold text-xs" style={{ color: isSelected ? palette.primary : palette.textPrimary }}>
                      {mode.title}
                    </div>
                    <div className="text-[10px] leading-snug mt-0.5" style={{ color: palette.textMuted }}>
                      {mode.sub}
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Voice & Audio Feedback Settings */}
          <div
            className="p-4 rounded-2xl border space-y-3"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Volume2 className="w-4 h-4" style={{ color: palette.primary }} />
                <span className="text-xs font-bold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
                  Voice & Audio Feedback (ஒலி அமைப்புகள்)
                </span>
              </div>
              <span
                className="text-[10px] font-semibold px-2 py-0.5 rounded-full"
                style={{
                  backgroundColor: !isMuted ? '#10B98125' : '#EF444420',
                  color: !isMuted ? '#10B981' : '#EF4444',
                }}
              >
                {!isMuted ? 'Sound Active (ஆன்)' : 'Sound Muted (ஆஃப்)'}
              </span>
            </div>

            <p className="text-[11px] leading-relaxed" style={{ color: palette.textSecondary }}>
              Plays a welcoming chime on message delivery and automatically speaks responses in warm Father tone.
            </p>

            <div className="flex flex-wrap items-center gap-2.5 pt-1">
              <button
                type="button"
                onClick={() => {
                  if (isMuted) setIsMuted(false);
                  testSound();
                }}
                disabled={isTestingSound}
                className="px-4 py-2 rounded-xl text-xs font-bold flex items-center gap-2 transition-all active:scale-95 shadow-xs disabled:opacity-50"
                style={{
                  backgroundColor: palette.primary,
                  color: '#FFFFFF',
                }}
              >
                <Volume2 className={`w-4 h-4 ${isTestingSound ? 'animate-bounce' : ''}`} />
                <span>{isTestingSound ? 'Testing Sound & Voice...' : '🔊 Test Sound Now (குரல் சோதனை)'}</span>
              </button>

              <button
                type="button"
                onClick={() => setIsMuted(!isMuted)}
                className="px-3 py-2 rounded-xl text-xs font-semibold border transition-all active:scale-95"
                style={{
                  backgroundColor: palette.surface,
                  borderColor: palette.border,
                  color: palette.textPrimary,
                }}
              >
                {isMuted ? '🔊 Unmute Audio' : '🔇 Mute Audio'}
              </button>
            </div>
          </div>

          {/* Gemini AI Integration */}
          <div
            className="p-4 rounded-2xl border space-y-3"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Bot className="w-4 h-4" style={{ color: palette.primary }} />
                <span className="text-xs font-bold uppercase tracking-wider" style={{ color: palette.textSecondary }}>
                  Intelligence Engine
                </span>
              </div>

              <span
                className="text-[10px] font-semibold px-2 py-0.5 rounded-full"
                style={{
                  backgroundColor: 'rgba(74, 222, 128, 0.15)',
                  color: '#4ade80',
                }}
              >
                ● Gemini API Active
              </span>
            </div>

            <form onSubmit={handleSaveApiKey} className="space-y-2">
              <div>
                <label className="block text-[11px] font-semibold mb-1 flex items-center gap-1" style={{ color: palette.textSecondary }}>
                  <Key className="w-3 h-3" />
                  <span>Google Gemini API Key (Server key active by default, or provide custom key)</span>
                </label>
                <div className="flex gap-2">
                  <input
                    type="password"
                    placeholder="Enter custom API key to override server..."
                    value={apiKeyInput}
                    onChange={(e) => setApiKeyInput(e.target.value)}
                    className="flex-1 px-3 py-2 rounded-xl border text-xs outline-none"
                    style={{
                      backgroundColor: palette.surface,
                      borderColor: palette.border,
                      color: palette.textPrimary,
                    }}
                  />
                  <button
                    type="submit"
                    className="px-3 py-2 rounded-xl text-xs font-semibold flex items-center gap-1 shadow-sm active:scale-95 transition-transform"
                    style={{
                      backgroundColor: palette.primary,
                      color: '#ffffff',
                    }}
                  >
                    <span>Save</span>
                    {isKeySaved && <CheckCircle className="w-3.5 h-3.5" />}
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-semibold mb-1" style={{ color: palette.textSecondary }}>
                  Model Alias
                </label>
                <select
                  value={geminiModel}
                  onChange={(e) => setGeminiModel(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl border text-xs outline-none"
                  style={{
                    backgroundColor: palette.surface,
                    borderColor: palette.border,
                    color: palette.textPrimary,
                  }}
                >
                  <option value="gemini-3.1-flash-lite">Gemini 3.1 Flash-Lite (Recommended Default, High Quota & Fast)</option>
                  <option value="gemini-3.8-flash">Gemini 3.8 Flash</option>
                  <option value="gemini-flash-latest">Gemini Flash Latest</option>
                </select>
              </div>
            </form>
          </div>

          {/* Audio Playback Switch */}
          <div
            className="p-4 rounded-2xl border flex items-center justify-between"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div className="flex items-center gap-2.5">
              <Volume2 className="w-4 h-4" style={{ color: palette.primary }} />
              <div>
                <div className="font-semibold text-xs" style={{ color: palette.textPrimary }}>
                  Automatic Spoken Response
                </div>
                <div className="text-[11px]" style={{ color: palette.textMuted }}>
                  Reads companion responses aloud using speech synthesis
                </div>
              </div>
            </div>

            <button
              onClick={() => setIsMuted(!isMuted)}
              className="px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all active:scale-95"
              style={{
                backgroundColor: !isMuted ? `${palette.primary}20` : palette.surface,
                borderColor: !isMuted ? palette.primary : palette.border,
                color: !isMuted ? palette.primary : palette.textMuted,
              }}
            >
              {!isMuted ? 'Enabled' : 'Muted'}
            </button>
          </div>

          {/* Statistics summary */}
          <div
            className="p-4 rounded-2xl border flex items-center justify-around text-center"
            style={{
              backgroundColor: palette.card,
              borderColor: palette.border,
            }}
          >
            <div>
              <div className="text-xl font-bold" style={{ color: palette.primary }}>
                {memories.length}
              </div>
              <div className="text-[11px]" style={{ color: palette.textSecondary }}>
                Preserved Memories
              </div>
            </div>

            <div className="w-px h-8" style={{ backgroundColor: palette.border }} />

            <div>
              <div className="text-xl font-bold" style={{ color: palette.secondary }}>
                {sessions.length}
              </div>
              <div className="text-[11px]" style={{ color: palette.textSecondary }}>
                Past Reflections
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      <ThemeSelectorModal isOpen={isThemeOpen} onClose={() => setIsThemeOpen(false)} />
      <ProfileModal isOpen={isProfileOpen} onClose={() => setIsProfileOpen(false)} />

      {/* About APDM Dialog */}
      {isAboutOpen && (
        <div
          id="about-modal"
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-fade-in"
          onClick={() => setIsAboutOpen(false)}
        >
          <div
            className="w-full max-w-md rounded-3xl border p-6 space-y-4 shadow-2xl"
            style={{
              backgroundColor: palette.surface,
              borderColor: palette.border,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${palette.primary}25`, color: palette.primary }}
              >
                <Heart className="w-5 h-5 fill-current" />
              </div>
              <div>
                <h3 className="font-bold text-base" style={{ color: palette.textPrimary }}>
                  APDM (Anbu Pathivu Ninaivugal)
                </h3>
                <p className="text-xs" style={{ color: palette.textSecondary }}>
                  Cherished Voices, Timeless Memories
                </p>
              </div>
            </div>

            <p className="text-xs leading-relaxed" style={{ color: palette.textPrimary }}>
              APDM is an empathetic, voice-first memorial companion created to honor and preserve beloved family memories, traditions, stories, and words of encouragement.
            </p>

            <div
              className="p-3 rounded-2xl border text-[11px] leading-relaxed flex items-start gap-2"
              style={{
                backgroundColor: `${palette.primary}12`,
                borderColor: `${palette.primary}30`,
                color: palette.textSecondary,
              }}
            >
              <ShieldAlert className="w-4 h-4 shrink-0 mt-0.5" style={{ color: palette.primary }} />
              <div>
                <span className="font-semibold" style={{ color: palette.textPrimary }}>
                  Memorial Dignity & Ethics:
                </span>{' '}
                APDM serves to comfort and inspire by reflecting preserved stories, never claiming to replace human relationships.
              </div>
            </div>

            <div className="text-center pt-2">
              <button
                onClick={() => setIsAboutOpen(false)}
                className="w-full py-2.5 rounded-xl text-xs font-semibold shadow-md active:scale-95"
                style={{ backgroundColor: palette.primary, color: '#ffffff' }}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
