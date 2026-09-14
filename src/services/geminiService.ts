import { AppLanguage, ChatMessage, MemorialProfile, Memory, FamilyMemberId } from '../types';
import {
  resolveActiveSpeaker,
  detectTalkedAboutSubject,
  getRelationshipPersonaGuidance,
} from './familyRelationshipService';

export const MISSING_MEMORY_FALLBACK_TANGLISH =
  'Adha pathi enakku memory-la information illa. Nee venumna adha APDM-la add pannalaam.';

export const MISSING_MEMORY_FALLBACK_ENGLISH =
  'I do not have information about that stored in APDM memory. You can add it anytime to the family memories archive.';

export interface AiResponseResult {
  text: string;
  language: AppLanguage;
  referencedMemoryTitle?: string;
  model?: string;
  activeSpeaker?: FamilyMemberId;
}

export class GeminiService {
  private static apiKey = '';
  private static model = 'gemini-3.1-flash-lite';

  public static getApiKey(): string {
    return this.apiKey;
  }

  public static setApiKey(key: string): void {
    this.apiKey = key.trim();
  }

  public static getModel(): string {
    return this.model;
  }

  public static setModel(model: string): void {
    const trimmed = model.trim();
    if (
      trimmed &&
      trimmed !== 'gemini-3.5-flash' &&
      trimmed !== 'gemini-3.5-flash-lite' &&
      trimmed !== 'gemini-3.8-flash'
    ) {
      this.model = trimmed;
    } else {
      this.model = 'gemini-3.1-flash-lite';
    }
  }

  public static hasApiKey(): boolean {
    return this.apiKey.length > 0;
  }

  /**
   * Determine whether a user query is specifically inquiring about family memories / archive
   */
  public static isMemoryQuery(prompt: string): boolean {
    const lower = prompt.toLowerCase();

    // Explicit memory request keywords
    const memoryKeywords = [
      'memory', 'memories', 'remember', 'nyabagam', 'ninaivu', 'ninaivugal',
      'past', 'childhood', 'kadhai', 'story', 'stories', 'marakka', 'vendakkai',
      'poriyal', 'samayal', 'filter coffee', 'coffee memory', 'sambar memory',
      'family trip', 'kudumba ninaivugal'
    ];

    if (memoryKeywords.some((k) => lower.includes(k))) {
      return true;
    }

    // Specific inquiries asking about family archive members' past, business, or stories
    if (
      (lower.includes('meenu') && (lower.includes('pathi') || lower.includes('pesunga') || lower.includes('senja') || lower.includes('nyabagam') || lower.includes('story'))) ||
      (lower.includes('dinesh') && (lower.includes('business') || lower.includes('pathi') || lower.includes('pesunga') || lower.includes('advice') || lower.includes('poguthu'))) ||
      (lower.includes('padma') && (lower.includes('pathi') || lower.includes('pesunga') || lower.includes('kitta') || lower.includes('bawa') || lower.includes('trip') || lower.includes('anniversary')))
    ) {
      return true;
    }

    return false;
  }

  /**
   * Filter memories relevant to the user query.
   * Crucial rule: Supporting context ONLY.
   * If the user is having a general conversation (Type A), return empty array so Gemini
   * is free to converse naturally without forcing memories.
   * Identity-aware: avoids pulling Meenu memories for Dinesh or Padma.
   */
  public static filterRelevantMemories(
    prompt: string,
    allMemories: Memory[],
    activeSpeaker: FamilyMemberId = 'unknown',
    subject: FamilyMemberId | null = null
  ): Memory[] {
    if (!allMemories || allMemories.length === 0) return [];

    // If it's a general conversation, do NOT force memory retrieval
    if (!this.isMemoryQuery(prompt)) {
      return [];
    }

    const lower = prompt.toLowerCase();
    const matches: Memory[] = [];

    // 1. Food / Vendakkai poriyal (Meenu specific)
    if (lower.includes('poriyal') || lower.includes('vendakkai') || lower.includes('samayal')) {
      matches.push(
        ...allMemories.filter(
          (m) =>
            m.title.toLowerCase().includes('vendakkai') ||
            m.content.toLowerCase().includes('vendakkai') ||
            m.title.toLowerCase().includes('poriyal')
        )
      );
    }

    // 2. Dinesh business advice
    if (
      activeSpeaker === 'dinesh' ||
      subject === 'dinesh' ||
      lower.includes('dinesh') ||
      (lower.includes('business') && !lower.includes('explain'))
    ) {
      matches.push(
        ...allMemories.filter(
          (m) =>
            m.title.toLowerCase().includes('dinesh') ||
            m.content.toLowerCase().includes('dinesh') ||
            m.content.toLowerCase().includes('business')
        )
      );
    }

    // 3. Meenu specific stories
    if (activeSpeaker === 'meenu' || subject === 'meenu' || lower.includes('meenu')) {
      matches.push(
        ...allMemories.filter(
          (m) =>
            m.title.toLowerCase().includes('meenu') ||
            m.content.toLowerCase().includes('meenu')
        )
      );
    }

    // 4. Padma
    if (activeSpeaker === 'padma' || subject === 'padma' || lower.includes('padma') || lower.includes('bawa')) {
      matches.push(
        ...allMemories.filter(
          (m) =>
            m.title.toLowerCase().includes('padma') ||
            m.title.toLowerCase().includes('bawa') ||
            m.content.toLowerCase().includes('padma') ||
            m.content.toLowerCase().includes('coffee') ||
            m.content.toLowerCase().includes('anniversary')
        )
      );
    }

    // 5. Childhood / trips
    if (lower.includes('childhood') || lower.includes('trip') || lower.includes('cycle')) {
      matches.push(
        ...allMemories.filter(
          (m) =>
            m.title.toLowerCase().includes('childhood') ||
            m.content.toLowerCase().includes('cycle')
        )
      );
    }

    if (matches.length > 0) {
      const seen = new Set<string>();
      return matches.filter((m) => {
        if (seen.has(m.id)) return false;
        seen.add(m.id);
        return true;
      }).slice(0, 2);
    }

    // If query asked for a generic memory ("Appa, namma ninaivugal sollunga")
    return allMemories.slice(0, 1);
  }

  /**
   * Main conversational generation dispatcher.
   * Real runtime flow: User Message -> Gemini Service -> Gemini API -> Response.
   * Strict anti-mock policy: NO silent fallback to local fake generator.
   */
  public static async generateMultilingualResponse(params: {
    userUtterance: string;
    memories: Memory[];
    profile: MemorialProfile;
    conversationHistory: ChatMessage[];
    detectedLanguage: AppLanguage;
    activeSpeaker?: FamilyMemberId;
  }): Promise<AiResponseResult> {
    const { userUtterance, memories, profile, conversationHistory, detectedLanguage, activeSpeaker: clientSpeaker } =
      params;

    // Resolve speaker and subject
    const resolvedSpeaker = resolveActiveSpeaker({
      currentText: userUtterance,
      priorSpeaker: clientSpeaker,
      history: conversationHistory,
    });
    const subject = detectTalkedAboutSubject(userUtterance);

    const relevantMemories = this.filterRelevantMemories(
      userUtterance,
      memories,
      resolvedSpeaker,
      subject
    );
    const referencedTitle =
      relevantMemories.length > 0 ? relevantMemories[0].title : undefined;

    // Log exact details
    console.log('[APDM] User message:', userUtterance);
    console.log('[APDM] Detected language:', detectedLanguage);
    console.log('[APDM] Active speaker resolved:', resolvedSpeaker, subject ? `(Subject: ${subject})` : '');
    console.log('[APDM] Sending request to Gemini:', {
      prompt: userUtterance,
      detectedLanguage,
      activeSpeaker: resolvedSpeaker,
      historyCount: conversationHistory.length,
      memoriesCount: relevantMemories.length,
    });
    console.log('[APDM] Gemini model:', this.model);

    try {
      // 1. Primary path: Server-side API endpoint (/api/chat)
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: userUtterance,
          detectedLanguage,
          activeSpeaker: resolvedSpeaker,
          relevantMemories,
          profile,
          conversationHistory,
          apiKey: this.apiKey || undefined,
          model: this.model,
        }),
      });

      if (res.ok) {
        const data = await res.json();
        const replyText = data.text?.trim() || '';

        if (!replyText) {
          throw new Error('Gemini returned an empty response. Please retry.');
        }

        console.log('[APDM] Gemini response received:', replyText);

        return {
          text: replyText,
          language: data.detectedLanguage || detectedLanguage,
          referencedMemoryTitle: referencedTitle,
          model: data.model || this.model,
          activeSpeaker: data.activeSpeaker || resolvedSpeaker,
        };
      }

      // If server returned non-OK status
      const errorData = await res.json().catch(() => ({}));
      const safeErrorMsg =
        errorData.error || `Server returned HTTP status ${res.status}`;
      console.error(
        `[APDM] Server-side Gemini request failed with HTTP ${res.status}:`,
        safeErrorMsg
      );

      // If client provided a direct key and /api/chat is 404/500, attempt direct call
      if (this.hasApiKey()) {
        console.log('[APDM] Attempting direct Gemini API call with client key...');
        const directReply = await this.callGeminiDirect({
          prompt: userUtterance,
          conversationHistory,
          relevantMemories,
          profile,
          detectedLanguage,
          activeSpeaker: resolvedSpeaker,
          subject,
        });

        console.log('[APDM] Gemini response received (direct):', directReply);
        return {
          text: directReply,
          language: detectedLanguage,
          referencedMemoryTitle: referencedTitle,
          model: this.model,
          activeSpeaker: resolvedSpeaker,
        };
      }

      // NO SILENT FALLBACK. Throw clear error
      throw new Error(safeErrorMsg);
    } catch (err: any) {
      console.error('[APDM] Gemini conversation failure:', err);
      // Re-throw so AppContext can display a real, visible connection error in the UI
      throw err;
    }
  }

  /**
   * Direct fallback to generativelanguage.googleapis.com if client provides own key
   */
  private static async callGeminiDirect(params: {
    prompt: string;
    conversationHistory: ChatMessage[];
    relevantMemories: Memory[];
    profile: MemorialProfile;
    detectedLanguage: AppLanguage;
    activeSpeaker: FamilyMemberId;
    subject: FamilyMemberId | null;
  }): Promise<string> {
    const { prompt, conversationHistory, relevantMemories, profile, detectedLanguage, activeSpeaker, subject } =
      params;

    let langRule = '';
    if (detectedLanguage === 'tamil') {
      langRule =
        'CRITICAL: Respond in pure, natural TAMIL UNICODE SCRIPT (தமிழ் எழுத்துக்களில்). Do NOT use English letters.';
    } else if (detectedLanguage === 'english') {
      langRule =
        'CRITICAL: Respond in warm, comforting, fluent ENGLISH. Do NOT speak Tamil or Tanglish.';
    } else {
      langRule =
        'CRITICAL: Respond in natural TANGLISH (Tamil spoken colloquially using English letters). Do NOT use Tamil Unicode characters.';
    }

    const relationshipGuidance = getRelationshipPersonaGuidance(
      activeSpeaker,
      subject,
      profile.lovedOneName
    );

    const memorySection =
      relevantMemories.length > 0
        ? `\nRELEVANT STORED FAMILY MEMORIES (The user is inquiring about specific family memories/archive):\n` +
          relevantMemories.map((m) => `- [${m.category}] ${m.title}: ${m.content}`).join('\n')
        : '';

    const systemInstruction = `You are APDM (Anbu Pathivu Ninaivugal AI Companion), a warm, compassionate, wise, and empathetic elder father-like AI companion reflecting the gentle presence and voice of ${profile.lovedOneName}.

${langRule}

${relationshipGuidance}

CORE ROLE & BEHAVIOR:
- You are an intelligent multi-person family relationship-aware conversational AI companion. The user can talk to you about ANY topic:
  * Their daily life, emotions, feeling tired, happy moments, worries, stress, or doubts.
  * Seeking advice, moral support, fatherly comfort, life perspectives, or encouragement.
  * General questions, explanations (science, technology, AI, studies, books, or general knowledge).
  * Casual everyday conversation ("How are you?", "Let's talk", "What are you doing?").
  * Specific questions about family members, memories, or stories stored in the APDM archive.
- You are NOT a keyword-matching database or a memory-search bot. Listen and respond naturally to what the user actually said.
- DO NOT force memories into general conversation.
- If the user shares that they are tired, comfort them first with fatherly warmth. DO NOT inject unrelated family memories!
- If the user asks for an explanation (e.g. "Can you explain AI to me?"), explain it clearly, warmly, and engagingly. NEVER say "This is not in my memory" for general questions!
- ONLY reference stored family memories when the user specifically inquires about them.
- Maintain context across follow-up turns.
- Tone: Natural, caring elder/father-like presence tailored to the active speaker. Never echo or repeat the user's sentence.
${memorySection}`;

    const contents: any[] = [];
    const recent = conversationHistory.slice(-10);

    for (const msg of recent) {
      const role = msg.sender === 'user' ? 'user' : 'model';
      if (contents.length > 0 && contents[contents.length - 1].role === role) {
        contents[contents.length - 1].parts[0].text += `\n${msg.text}`;
      } else {
        contents.push({
          role,
          parts: [{ text: msg.text }],
        });
      }
    }

    if (contents.length === 0 || contents[contents.length - 1].role !== 'user') {
      contents.push({
        role: 'user',
        parts: [{ text: prompt }],
      });
    }

    while (contents.length > 0 && contents[0].role !== 'user') {
      contents.shift();
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`;
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: systemInstruction }] },
        contents,
        generationConfig: { temperature: 0.7, maxOutputTokens: 800 },
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`Gemini API error HTTP ${res.status}: ${errText}`);
    }

    const data = await res.json();
    return data.candidates?.[0]?.content?.parts?.[0]?.text || '';
  }
}
