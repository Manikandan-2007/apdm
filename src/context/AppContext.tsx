import React, { createContext, useContext, useEffect, useState } from 'react';
import {
  AppLanguage,
  ChatMessage,
  ConversationSession,
  FamilyMemberId,
  MemorialProfile,
  Memory,
  MemoryCategoryType,
  ThemePalette,
  ThemePresetId,
  VoiceState,
} from '../types';
import { THEME_PALETTES } from '../constants/theme';
import { detectLanguage } from '../services/languageDetector';
import { GeminiService } from '../services/geminiService';
import { speechService } from '../services/speechService';
import { resolveActiveSpeaker } from '../services/familyRelationshipService';

// Pre-seeded authentic initial memories from Flutter App
const INITIAL_MEMORIES: Memory[] = [
  {
    id: 'mem_1',
    title: 'Vendakkai Poriyal Samayal',
    content:
      'Sunday aana kitchen-la Appa ninnu Meenu-kaaga romba anba vendakkai poriyal senju tharuvaaru. Meenu pakkathulaye ninnu chinna chinna kathaigal pesuvaa.',
    category: 'favorites',
    memoryDate: '2018-04-14',
    createdAt: '2024-01-15T10:00:00Z',
    tags: ['Meenu', 'Samayal', 'Vendakkai', 'Sunday'],
    emotionTag: 'Heartwarming 🏡',
  },
  {
    id: 'mem_2',
    title: 'Dinesh Business Advice',
    content:
      'Dinesh pudhu business aarambikumbodhu Appa sonna mukkiyamaana vaarthai: "Tholvi vandha bayapadaatha da, un nermaiyum uzhaippum thaan un unmaiyana balam."',
    category: 'stories',
    memoryDate: '2020-08-10',
    createdAt: '2024-01-16T12:00:00Z',
    tags: ['Dinesh', 'Business', 'Advice', 'Uzhaipu'],
    emotionTag: 'Inspiring 🌟',
  },
  {
    id: 'mem_3',
    title: 'Padma 30th Anniversary Trip',
    content:
      'Padma-vum Appavum thirumanamaana 30-aam varusha ninaivaaga Rameswaram koyilukku poi amadhargalaana dharisanam seidhaar. Bawa eppavum Padma kaaga mallipoo vaangi varuvaar.',
    category: 'family',
    memoryDate: '2021-02-22',
    createdAt: '2024-01-17T09:30:00Z',
    tags: ['Padma', 'Bawa', 'Anniversary', 'Kovil'],
    emotionTag: 'Sentimental ❤️',
  },
  {
    id: 'mem_4',
    title: 'Morning Kaapi & Sambar Routine',
    content:
      'Kaalaila 6:30 manikku Appa filter kaapi pottu, Padma senja thalippu sambar vasanaiyoda veedae oru azhagana amadhiyil irukkum. Appa paper padichutte katha solluvaar.',
    category: 'personal',
    memoryDate: '2019-11-05',
    createdAt: '2024-01-18T08:00:00Z',
    tags: ['Kaapi', 'Sunday', 'Sambar', 'Routine'],
    emotionTag: 'Peaceful 🕊️',
  },
  {
    id: 'mem_5',
    title: 'Evening Bicycle Walks with Children',
    content:
      'Chinna vayasula Meenu-vaiyum Dinesh-aiyum cycle munnadi ukaara vechu sayangaalam park-ku koottitu povadhil Appavukku periya santhosham.',
    category: 'stories',
    memoryDate: '2008-06-18',
    createdAt: '2024-01-19T17:00:00Z',
    tags: ['Childhood', 'Cycle', 'Park', 'Meenu', 'Dinesh'],
    emotionTag: 'Cherished 🌸',
  },
];

const INITIAL_PROFILE: MemorialProfile = {
  id: 'profile_anandhan',
  lovedOneName: 'Anandhan',
  relationship: 'Family Companion',
  lifespan: '',
  biography:
    'A warm, empathetic conversational companion preserving cherished family stories, advice, and daily memories for Meenu, Dinesh, and Padma.',
  favoritePhrase: 'Porumaiyum unmaiyum eppavum un kooda irukattum da.',
  avatarInitials: 'SU',
};

const INITIAL_SESSIONS: ConversationSession[] = [
  {
    id: 'sess_1',
    title: 'Evening Conversation',
    startedAt: new Date(Date.now() - 3600000 * 24 * 2).toISOString(),
    durationSeconds: 240,
    summaryPreview: 'Meenu college studies & evening filter coffee memories.',
    topics: ['Meenu', 'Studies', 'Kaapi'],
    activeSpeaker: 'meenu',
    messages: [
      {
        id: 'msg_s1_1',
        text: 'Appa, innikku college-la konjam stress-a irundhuchu...',
        sender: 'user',
        speakerId: 'meenu',
        timestamp: new Date(Date.now() - 3600000 * 24 * 2).toISOString(),
        detectedLanguage: 'tanglish',
      },
      {
        id: 'msg_s1_2',
        text: 'En chellam Meenu, stress-a irukaadha da ❤️. Appa eppavum solvadhupola, manasa amaidhiya vechukkonga. Nalla padichu dhairiyama iru, ellame nalla nadakkum 🌟.',
        sender: 'ai',
        speakerId: 'meenu',
        timestamp: new Date(Date.now() - 3600000 * 24 * 2 + 10000).toISOString(),
        detectedLanguage: 'tanglish',
        memoryContextRef: 'Vendakkai Poriyal Samayal',
      },
    ],
  },
];

interface AppContextType {
  memories: Memory[];
  addMemory: (memory: Omit<Memory, 'id' | 'createdAt'>) => void;
  updateMemory: (memory: Memory) => void;
  deleteMemory: (id: string) => void;

  sessions: ConversationSession[];
  activeSession: ConversationSession | null;
  startNewSession: (customTitle?: string) => void;
  loadSession: (sessionId: string) => void;
  renameSession: (sessionId: string, newTitle: string) => void;
  deleteSession: (sessionId: string) => void;
  clearCurrentChat: () => void;
  retryLastMessage: () => Promise<void>;
  switchActiveProfile: (speaker: FamilyMemberId) => void;

  profile: MemorialProfile;
  updateProfile: (profile: MemorialProfile) => void;

  themePreset: ThemePresetId;
  setThemePreset: (id: ThemePresetId) => void;
  palette: ThemePalette;
  isDarkMode: boolean;
  setIsDarkMode: (val: boolean) => void;

  languageMode: 'auto' | 'tamil' | 'tanglish' | 'english';
  setLanguageMode: (mode: 'auto' | 'tamil' | 'tanglish' | 'english') => void;

  geminiApiKey: string;
  setGeminiApiKey: (key: string) => void;
  geminiModel: string;
  setGeminiModel: (model: string) => void;

  activeSpeaker: FamilyMemberId;
  setActiveSpeaker: (speaker: FamilyMemberId) => void;

  isMuted: boolean;
  setIsMuted: (val: boolean) => void;

  voiceState: VoiceState;
  liveTranscript: string;
  soundLevel: number;
  isAiThinking: boolean;
  activeAudioMessageId: string | null;
  isSpeaking: boolean;
  speechError: boolean;

  sendMessage: (text: string) => Promise<void>;
  playAudio: (messageId: string, text: string, lang?: AppLanguage) => Promise<void>;
  stopAudio: () => void;
  testSound: (customText?: string) => Promise<void>;
  isTestingSound: boolean;
}

const AppContext = createContext<AppContextType | null>(null);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Memories
  const [memories, setMemories] = useState<Memory[]>(() => {
    try {
      const saved = localStorage.getItem('apdm_memories');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed)) return parsed;
      }
    } catch (e) {
      console.warn('[APDM] Failed to parse memories from localStorage:', e);
    }
    return INITIAL_MEMORIES;
  });

  // Profile (Sanitized against historical deceased labels)
  const [profile, setProfile] = useState<MemorialProfile>(() => {
    try {
      const saved = localStorage.getItem('apdm_profile');
      if (saved) {
        const parsed = JSON.parse(saved);
        return {
          ...parsed,
          lovedOneName: parsed.lovedOneName === 'Sundaram (Appa)' ? 'Anandhan' : (parsed.lovedOneName || 'Anandhan'),
          relationship: parsed.relationship === 'Father / Bawa' ? 'Family Companion' : (parsed.relationship || 'Family Companion'),
          lifespan: '',
        };
      }
    } catch (e) {
      console.warn('[APDM] Failed to parse profile from localStorage:', e);
    }
    return INITIAL_PROFILE;
  });

  // Sessions
  const [sessions, setSessions] = useState<ConversationSession[]>(() => {
    try {
      const saved = localStorage.getItem('apdm_sessions');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed) && parsed.length > 0) return parsed;
      }
    } catch (e) {
      console.warn('[APDM] Failed to parse sessions from localStorage:', e);
    }
    return INITIAL_SESSIONS;
  });

  const [activeSession, setActiveSession] = useState<ConversationSession | null>(() => {
    return sessions.length > 0 ? sessions[0] : null;
  });

  const [activeSpeaker, setActiveSpeaker] = useState<FamilyMemberId>(() => {
    return sessions.length > 0 && sessions[0].activeSpeaker ? sessions[0].activeSpeaker : 'unknown';
  });

  // Theme
  const [themePreset, setThemePreset] = useState<ThemePresetId>(() => {
    const saved = localStorage.getItem('apdm_theme');
    return (saved as ThemePresetId) || 'midnight_amber';
  });

  const [isDarkMode, setIsDarkMode] = useState<boolean>(() => {
    const saved = localStorage.getItem('apdm_dark_mode');
    return saved !== null ? saved === 'true' : true;
  });

  // Language & Gemini
  const [languageMode, setLanguageMode] = useState<'auto' | 'tamil' | 'tanglish' | 'english'>('auto');
  const [geminiApiKey, setGeminiApiKeyState] = useState<string>(() => {
    return localStorage.getItem('apdm_gemini_key') || '';
  });
  const [geminiModel, setGeminiModelState] = useState<string>(() => {
    const saved = localStorage.getItem('apdm_gemini_model');
    if (
      saved &&
      saved !== 'gemini-3.5-flash' &&
      saved !== 'gemini-3.5-flash-lite' &&
      saved !== 'gemini-3.8-flash'
    ) {
      return saved;
    }
    return 'gemini-3.1-flash-lite';
  });
  const [isMuted, setIsMutedState] = useState<boolean>(() => {
    const saved = localStorage.getItem('apdm_is_muted');
    return saved === 'true';
  });
  const [isTestingSound, setIsTestingSound] = useState<boolean>(false);

  const setIsMuted = (val: boolean) => {
    setIsMutedState(val);
    localStorage.setItem('apdm_is_muted', String(val));
    if (val) {
      speechService.stopSpeaking();
    }
  };

  // Voice & Chat State
  const [voiceState, setVoiceState] = useState<VoiceState>('ready');
  const [liveTranscript, setLiveTranscript] = useState<string>('');
  const [soundLevel, setSoundLevel] = useState<number>(0.2);
  const [isAiThinking, setIsAiThinking] = useState<boolean>(false);
  const [activeAudioMessageId, setActiveAudioMessageId] = useState<string | null>(null);
  const [isSpeaking, setIsSpeaking] = useState<boolean>(false);
  const [speechError, setSpeechError] = useState<boolean>(false);

  // Sync with services
  useEffect(() => {
    GeminiService.setApiKey(geminiApiKey);
  }, [geminiApiKey]);

  useEffect(() => {
    GeminiService.setModel(geminiModel);
  }, [geminiModel]);

  useEffect(() => {
    localStorage.setItem('apdm_memories', JSON.stringify(memories));
  }, [memories]);

  useEffect(() => {
    localStorage.setItem('apdm_profile', JSON.stringify(profile));
  }, [profile]);

  useEffect(() => {
    localStorage.setItem('apdm_sessions', JSON.stringify(sessions));
  }, [sessions]);

  useEffect(() => {
    localStorage.setItem('apdm_theme', themePreset);
  }, [themePreset]);

  useEffect(() => {
    localStorage.setItem('apdm_dark_mode', String(isDarkMode));
  }, [isDarkMode]);

  useEffect(() => {
    if (languageMode === 'tamil') {
      speechService.setRecognitionLanguage('ta-IN');
    } else if (languageMode === 'english') {
      speechService.setRecognitionLanguage('en-IN');
    } else {
      // 'auto' or 'tanglish': Default to ta-IN for reliable Tamil & Tanglish speech recognition
      speechService.setRecognitionLanguage('ta-IN');
    }
  }, [languageMode]);

  // Speech subscriptions
  useEffect(() => {
    const unSubState = speechService.subscribeState((st) => setVoiceState(st));
    const unSubTranscript = speechService.subscribeTranscript((tr) => setLiveTranscript(tr));
    const unSubSound = speechService.subscribeSoundLevel((sl) => setSoundLevel(sl));
    const unSubSpeaking = speechService.subscribeSpeaking((speaking) => {
      setIsSpeaking(speaking);
      if (!speaking) {
        setActiveAudioMessageId(null);
      }
    });
    const unSubError = speechService.subscribeSpeechError((hasErr) => {
      setSpeechError(hasErr);
    });

    return () => {
      unSubState();
      unSubTranscript();
      unSubSound();
      unSubSpeaking();
      unSubError();
    };
  }, []);

  const palette = THEME_PALETTES[themePreset] || THEME_PALETTES.midnight_amber;

  // Actions
  const addMemory = (newMemData: Omit<Memory, 'id' | 'createdAt'>) => {
    const newMemory: Memory = {
      ...newMemData,
      id: `mem_${Date.now()}`,
      createdAt: new Date().toISOString(),
    };
    setMemories((prev) => [newMemory, ...prev]);
  };

  const updateMemory = (updated: Memory) => {
    setMemories((prev) => prev.map((m) => (m.id === updated.id ? updated : m)));
  };

  const deleteMemory = (id: string) => {
    setMemories((prev) => prev.filter((m) => m.id !== id));
  };

  const startNewSession = (customTitle?: string) => {
    const title = customTitle || 'Conversation with APDM';
    const newSession: ConversationSession = {
      id: `sess_${Date.now()}`,
      title,
      startedAt: new Date().toISOString(),
      durationSeconds: 0,
      messages: [],
      summaryPreview: 'New conversation started.',
      topics: [],
      activeSpeaker: activeSpeaker !== 'unknown' ? activeSpeaker : 'unknown',
    };
    setSessions((prev) => [newSession, ...prev]);
    setActiveSession(newSession);
    speechService.stopSpeaking();
    setActiveAudioMessageId(null);
  };

  const clearCurrentChat = () => {
    if (!activeSession) return;
    const clearedSession: ConversationSession = {
      ...activeSession,
      messages: [],
      summaryPreview: 'Chat cleared.',
    };
    setActiveSession(clearedSession);
    setSessions((prev) =>
      prev.map((s) => (s.id === clearedSession.id ? clearedSession : s))
    );
    speechService.stopSpeaking();
    setActiveAudioMessageId(null);
  };

  const switchActiveProfile = (speaker: FamilyMemberId) => {
    setActiveSpeaker(speaker);
    if (activeSession) {
      const updated: ConversationSession = {
        ...activeSession,
        activeSpeaker: speaker,
      };
      setActiveSession(updated);
      setSessions((prev) =>
        prev.map((s) => (s.id === updated.id ? updated : s))
      );
    }
  };

  const retryLastMessage = async () => {
    if (!activeSession || isAiThinking) return;
    const lastUserMsg = [...activeSession.messages]
      .reverse()
      .find((m) => m.sender === 'user');
    if (lastUserMsg) {
      // Remove trailing error AI messages
      const filtered = activeSession.messages.filter((m) => !m.isError);
      // Remove the last user message as sendMessage will append it
      const cleaned = filtered.slice(0, -1);
      const cleanedSession = { ...activeSession, messages: cleaned };
      setActiveSession(cleanedSession);
      setSessions((prev) =>
        prev.map((s) => (s.id === cleanedSession.id ? cleanedSession : s))
      );
      await sendMessage(lastUserMsg.text);
    }
  };

  const loadSession = (sessionId: string) => {
    const found = sessions.find((s) => s.id === sessionId);
    if (found) {
      setActiveSession(found);
      setActiveSpeaker(found.activeSpeaker || 'unknown');
    }
  };

  const renameSession = (sessionId: string, newTitle: string) => {
    setSessions((prev) =>
      prev.map((s) => (s.id === sessionId ? { ...s, title: newTitle } : s))
    );
    if (activeSession?.id === sessionId) {
      setActiveSession((prev) => (prev ? { ...prev, title: newTitle } : null));
    }
  };

  const deleteSession = (sessionId: string) => {
    setSessions((prev) => {
      const next = prev.filter((s) => s.id !== sessionId);
      if (activeSession?.id === sessionId) {
        setActiveSession(next.length > 0 ? next[0] : null);
      }
      return next;
    });
  };

  const updateProfile = (p: MemorialProfile) => {
    setProfile(p);
  };

  const setGeminiApiKey = (key: string) => {
    setGeminiApiKeyState(key);
    localStorage.setItem('apdm_gemini_key', key);
  };

  const setGeminiModel = (m: string) => {
    const chosen =
      m &&
      m !== 'gemini-3.5-flash' &&
      m !== 'gemini-3.5-flash-lite' &&
      m !== 'gemini-3.8-flash'
        ? m
        : 'gemini-3.1-flash-lite';
    setGeminiModelState(chosen);
    localStorage.setItem('apdm_gemini_model', chosen);
  };

  const playAudio = async (messageId: string, text: string, lang?: AppLanguage) => {
    speechService.unlockAudio();
    if (activeAudioMessageId === messageId && speechService.getIsSpeaking()) {
      speechService.stopSpeaking();
      setActiveAudioMessageId(null);
      return;
    }
    setActiveAudioMessageId(messageId);
    try {
      await speechService.speak(text, lang);
    } catch (err) {
      console.error('[TTS] Error in playAudio:', err);
    } finally {
      setActiveAudioMessageId((curr) => (curr === messageId ? null : curr));
    }
  };

  const stopAudio = () => {
    speechService.stopSpeaking();
    setActiveAudioMessageId(null);
  };

  const testSound = async (customPrompt?: string) => {
    speechService.unlockAudio();
    setIsTestingSound(true);
    try {
      await speechService.testSound(customPrompt);
    } finally {
      setIsTestingSound(false);
    }
  };

  const sendMessage = async (text: string) => {
    if (!text.trim()) return;

    // Trigger immediate audio feedback and unlock browser audio pipeline
    speechService.unlockAudio();
    speechService.playChime('send');

    let currentSession = activeSession;
    if (!currentSession) {
      const title = `Reflection: ${text.slice(0, 24)}...`;
      currentSession = {
        id: `sess_${Date.now()}`,
        title,
        startedAt: new Date().toISOString(),
        durationSeconds: 0,
        messages: [],
        summaryPreview: text,
        topics: [],
      };
      setSessions((prev) => [currentSession!, ...prev]);
      setActiveSession(currentSession);
    }

    // Dynamic language detection for EVERY message
    const detectedLang: AppLanguage =
      languageMode === 'auto'
        ? detectLanguage(text)
        : languageMode;

    const resolvedSpeaker = resolveActiveSpeaker({
      currentText: text,
      priorSpeaker: activeSpeaker,
      history: currentSession.messages,
    });
    setActiveSpeaker(resolvedSpeaker);

    const userMessage: ChatMessage = {
      id: `msg_user_${Date.now()}`,
      conversationId: currentSession.id,
      text: text.trim(),
      sender: 'user',
      timestamp: new Date().toISOString(),
      detectedLanguage: detectedLang,
      speakerId: resolvedSpeaker,
    };

    const updatedMessagesWithUser = [...currentSession.messages, userMessage];

    // Update active session locally
    const updatedSessionWithUser: ConversationSession = {
      ...currentSession,
      activeSpeaker: resolvedSpeaker,
      messages: updatedMessagesWithUser,
      summaryPreview: text,
    };
    setActiveSession(updatedSessionWithUser);
    setSessions((prev) =>
      prev.map((s) => (s.id === updatedSessionWithUser.id ? updatedSessionWithUser : s))
    );

    setIsAiThinking(true);
    console.log('[Gemini] input:', text);

    try {
      const response = await GeminiService.generateMultilingualResponse({
        userUtterance: text,
        memories,
        profile,
        conversationHistory: updatedMessagesWithUser,
        detectedLanguage: detectedLang,
        activeSpeaker: resolvedSpeaker,
      });

      const finalSpeaker = response.activeSpeaker || resolvedSpeaker;
      setActiveSpeaker(finalSpeaker);

      // Detect response language dynamically before TTS
      const actualResponseLang = detectLanguage(response.text);
      const responseLangLabel =
        actualResponseLang === 'tamil'
          ? 'Tamil'
          : actualResponseLang === 'tanglish'
          ? 'Tanglish'
          : 'English';
      console.log('[Gemini] response language:', responseLangLabel);

      // Adapt STT recognition language for the next turn
      if (languageMode === 'auto') {
        if (actualResponseLang === 'english' && detectedLang === 'english') {
          speechService.setRecognitionLanguage('en-IN');
        } else {
          speechService.setRecognitionLanguage('ta-IN');
        }
      }

      const aiMessage: ChatMessage = {
        id: `msg_ai_${Date.now()}`,
        conversationId: currentSession.id,
        text: response.text,
        sender: 'ai',
        timestamp: new Date().toISOString(),
        detectedLanguage: actualResponseLang,
        memoryContextRef: response.referencedMemoryTitle,
        speakerId: finalSpeaker,
      };

      const finalMessages = [...updatedMessagesWithUser, aiMessage];
      const finalSession: ConversationSession = {
        ...currentSession,
        activeSpeaker: finalSpeaker,
        messages: finalMessages,
        summaryPreview: response.text.slice(0, 60),
      };

      setActiveSession(finalSession);
      setSessions((prev) =>
        prev.map((s) => (s.id === finalSession.id ? finalSession : s))
      );

      console.log('[TTS] Response received:', response.text);

      // Play arrival chime and auto speak if not muted
      speechService.playChime('receive');
      if (!isMuted) {
        // Small delay to allow the receive chime to ring before speech starts
        setTimeout(() => {
          playAudio(aiMessage.id, aiMessage.text, actualResponseLang);
        }, 250);
      }
    } catch (err: any) {
      console.error('[APDM] Error in AI turn:', err);
      speechService.playChime('receive');

      const errString = String(err?.message || err || '');
      const isRateLimit =
        errString.includes('429') ||
        errString.toLowerCase().includes('rate limit') ||
        errString.toLowerCase().includes('quota') ||
        errString.toLowerCase().includes('resource_exhausted');
      const isOverloaded =
        errString.includes('503') ||
        errString.toLowerCase().includes('overloaded') ||
        errString.toLowerCase().includes('service unavailable');

      let errorNotice = 'Unable to connect to the AI right now. Please try again.';
      if (isRateLimit) {
        errorNotice =
          'The AI companion is currently busy due to high demand (Rate limit / 429). Please wait a few moments and tap Retry, or enter a custom Gemini API key in Settings.';
      } else if (isOverloaded) {
        errorNotice =
          'The AI companion service is momentarily overloaded (503 Service Unavailable). Please wait a moment and tap Retry.';
      }

      const errorAiMessage: ChatMessage = {
        id: `msg_err_${Date.now()}`,
        conversationId: currentSession.id,
        text: errorNotice,
        sender: 'ai',
        timestamp: new Date().toISOString(),
        detectedLanguage: detectedLang,
        isError: true,
      };

      const finalMessages = [...updatedMessagesWithUser, errorAiMessage];
      const finalSession: ConversationSession = {
        ...currentSession,
        activeSpeaker: resolvedSpeaker,
        messages: finalMessages,
        summaryPreview: errorNotice,
      };

      setActiveSession(finalSession);
      setSessions((prev) =>
        prev.map((s) => (s.id === finalSession.id ? finalSession : s))
      );
    } finally {
      setIsAiThinking(false);
    }
  };

  return (
    <AppContext.Provider
      value={{
        memories,
        addMemory,
        updateMemory,
        deleteMemory,

        sessions,
        activeSession,
        startNewSession,
        loadSession,
        renameSession,
        deleteSession,
        clearCurrentChat,
        retryLastMessage,
        switchActiveProfile,

        profile,
        updateProfile,

        themePreset,
        setThemePreset,
        palette,
        isDarkMode,
        setIsDarkMode,

        languageMode,
        setLanguageMode,

        geminiApiKey,
        setGeminiApiKey,
        geminiModel,
        setGeminiModel,

        activeSpeaker,
        setActiveSpeaker,

        isMuted,
        setIsMuted,

        voiceState,
        liveTranscript,
        soundLevel,
        isAiThinking,
        activeAudioMessageId,
        isSpeaking,
        speechError,

        sendMessage,
        playAudio,
        stopAudio,
        testSound,
        isTestingSound,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = (): AppContextType => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
