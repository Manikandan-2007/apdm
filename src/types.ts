export type AppLanguage = 'tamil' | 'english' | 'tanglish';

export type FamilyMemberId = 'meenu' | 'dinesh' | 'padma' | 'unknown';

export interface FamilyMemberInfo {
  id: FamilyMemberId;
  displayName: string;
  tamilName: string;
  relationship: string;
  avatarIcon: string;
  description: string;
}

export type MessageSender = 'user' | 'ai';

export type AudioPlaybackState = 'none' | 'playing' | 'paused' | 'completed';

export type VoiceState = 'ready' | 'listening' | 'processing' | 'speaking';

export type MemoryCategoryType =
  | 'personal'
  | 'family'
  | 'stories'
  | 'events'
  | 'favorites'
  | 'messages';

export interface Memory {
  id: string;
  title: string;
  content: string;
  category: MemoryCategoryType;
  memoryDate?: string;
  createdAt: string;
  tags: string[];
  emotionTag?: string;
}

export interface ChatMessage {
  id: string;
  conversationId?: string;
  text: string;
  sender: MessageSender;
  speakerId?: FamilyMemberId;
  timestamp: string;
  isPartial?: boolean;
  detectedLanguage: AppLanguage;
  audioState?: AudioPlaybackState;
  audioUrl?: string;
  memoryContextRef?: string;
  isError?: boolean;
}

export interface ConversationSession {
  id: string;
  title: string;
  startedAt: string;
  durationSeconds: number;
  messages: ChatMessage[];
  summaryPreview: string;
  topics: string[];
  activeSpeaker?: FamilyMemberId;
}

export interface MemorialProfile {
  id: string;
  lovedOneName: string;
  relationship: string; // e.g. "Father", "Mother", "Grandmother", "Spouse"
  lifespan: string; // e.g. "1954 – 2022"
  biography: string;
  favoritePhrase: string;
  avatarInitials: string;
}

export type ThemePresetId =
  | 'midnight_amber'
  | 'temple_gold'
  | 'sandalwood_rose'
  | 'forest_sage'
  | 'royal_amethyst'
  | 'amoled_onyx'
  | 'light_linen';

export interface ThemePalette {
  id: ThemePresetId;
  englishName: string;
  tamilName: string;
  description: string;
  background: string;
  surface: string;
  card: string;
  border: string;
  primary: string;
  primaryLight: string;
  primaryDark: string;
  accentGlow: string;
  secondary: string;
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
}

export interface SuggestionCategory {
  id: string;
  title: string;
  icon: string;
  shortChip: string;
}

export interface SuggestionPrompt {
  categoryId: string;
  prompt: string;
  shortLabel: string;
}
