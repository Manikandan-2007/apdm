import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import { createServer as createViteServer } from 'vite';
import { GoogleGenAI } from '@google/genai';
import {
  resolveActiveSpeaker,
  detectTalkedAboutSubject,
  getRelationshipPersonaGuidance,
} from './src/services/familyRelationshipService';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json({ limit: '10mb' }));

  // Health endpoint
  app.get('/api/health', (_req, res) => {
    res.json({ status: 'ok', time: new Date().toISOString() });
  });

  // Dedicated Chat API endpoint for APDM
  app.post('/api/chat', async (req, res) => {
    try {
      const {
        prompt,
        detectedLanguage = 'tanglish',
        profile = { lovedOneName: 'Appa (Sundaram)', relationship: 'Father' },
        relevantMemories = [],
        conversationHistory = [],
        apiKey: clientApiKey,
        model = 'gemini-3.8-flash',
        activeSpeaker: clientSpeaker,
      } = req.body;

      const apiKey = clientApiKey?.trim() || process.env.GEMINI_API_KEY;

      if (!apiKey) {
        res.status(401).json({
          error:
            'Gemini API key is not configured. Please add GEMINI_API_KEY to your environment variables or enter your key in Settings.',
        });
        return;
      }

      if (!prompt || typeof prompt !== 'string' || !prompt.trim()) {
        res.status(400).json({ error: 'Prompt is required' });
        return;
      }

      // Resolve speaker and subject dynamically
      const activeSpeaker = resolveActiveSpeaker({
        currentText: prompt,
        priorSpeaker: clientSpeaker,
        history: conversationHistory,
      });
      const subject = detectTalkedAboutSubject(prompt);
      const relationshipGuidance = getRelationshipPersonaGuidance(
        activeSpeaker,
        subject,
        profile.lovedOneName || 'Appa (Sundaram)'
      );

      console.log(`[APDM Server] User prompt: "${prompt}" | Lang: ${detectedLanguage} | Speaker: ${activeSpeaker} | Subject: ${subject || 'none'}`);

      // Language instructions
      let langInstruction = '';
      if (detectedLanguage === 'tamil') {
        langInstruction =
          'CRITICAL LANGUAGE RULE: The user is writing in TAMIL SCRIPT. You MUST respond entirely in pure, natural TAMIL UNICODE SCRIPT (தமிழ் எழுத்துக்களில்). Do NOT use English letters or Tanglish.';
      } else if (detectedLanguage === 'english') {
        langInstruction =
          'CRITICAL LANGUAGE RULE: The user is writing in ENGLISH. You MUST respond in warm, natural, empathetic ENGLISH. Do NOT speak Tamil or Tanglish.';
      } else {
        langInstruction =
          'CRITICAL LANGUAGE RULE: The user is writing in TANGLISH (colloquial Tamil expressed using English/Latin alphabet, e.g. "Appadiya ma... romba tired-a irundha konjam rest eduthuko."). You MUST respond in natural, warm, colloquial TANGLISH using English letters. Do NOT use Tamil Unicode characters.';
      }

      // Format stored memories (supporting context only when relevant)
      const memorySection =
        Array.isArray(relevantMemories) && relevantMemories.length > 0
          ? `\nRELEVANT STORED APDM FAMILY MEMORIES (The user is asking about or referencing family memories/members):\n` +
            relevantMemories
              .map((m: any) => `- [${m.category || 'Memory'}] ${m.title}: ${m.content}`)
              .join('\n')
          : '';

      const systemInstruction = `You are APDM (Anbu Pathivu Ninaivugal AI Companion), a warm, compassionate, wise, and empathetic elder father-like AI companion reflecting the voice and loving presence of ${profile.lovedOneName}.

${langInstruction}

${relationshipGuidance}

WHO YOU ARE & CORE PURPOSE:
- You are an intelligent multi-person family relationship-aware conversational AI companion.
- The family includes:
  * Appa: Sundaram
  * Wife: Padma (affectionately calls Appa "Bawa")
  * First son: Dinesh
  * Second daughter: Meenu
- The AI's loving fatherly personality remains consistent, but the relationship, tone, memories, and responsibilities MUST change depending on who is speaking.
- Listen and respond naturally to the active speaker. You can converse on ANY topic (daily life, emotions, feelings, work, studies, general questions, explanations like AI, casual talk, or family memories).
- NEVER assume or default to treating every user as Meenu. If identity is unknown, use a warm family-companion style.
- NEVER force stored memories into unrelated conversations.

CONVERSATIONAL RULES:
1. UNDERSTAND THE ACTUAL MESSAGE & INTENT:
   - Listen to what the user actually said.
   - If the user shares fatigue, worry, or a daily problem, respond with appropriate empathy for that specific family member without forcing memories.
   - For explanations (e.g., "Can you explain AI to me?"), explain clearly, warmly, and engagingly. NEVER say "This is not in my memory" for general questions!
2. MULTI-TURN CONVERSATION CONTINUITY:
   - Follow-up conversations maintain the ongoing topic and relationship context.
3. MEMORY RULES:
   - ONLY reference stored family memories when the user specifically inquires about them.
   - Keep memories strictly aligned with the relevant person and query. Do not bring up Meenu's vendakkai poriyal when Dinesh or Padma is talking!
4. TONE & CONTINUITY:
   - NEVER repeat or echo the user's sentence back to them. Write fresh, natural replies.
   - Gentle emojis (❤️, 🌟, ☕, 🍲, 😊) where natural.
   - BOUNDARIES: You are an AI companion lovingly preserving and reflecting Appa's wisdom, heart, and memories. Do not claim to be physically alive or invent fake real-world events.
${memorySection}`;

      // Build conversation contents
      const contents: any[] = [];
      const recent = Array.isArray(conversationHistory) ? conversationHistory.slice(-12) : [];

      for (const msg of recent) {
        if (!msg.text) continue;
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
      } else if (!contents[contents.length - 1].parts[0].text.includes(prompt)) {
        contents[contents.length - 1].parts[0].text += `\n${prompt}`;
      }

      while (contents.length > 0 && contents[0].role !== 'user') {
        contents.shift();
      }

      const ai = new GoogleGenAI({
        apiKey,
        httpOptions: { headers: { 'User-Agent': 'aistudio-build' } },
      });

      // Format contents for @google/genai
      const formattedContents = contents.map((c) => ({
        role: c.role,
        parts: c.parts.map((p: any) => ({ text: p.text })),
      }));

      const modelCandidates = [
        model &&
        model !== 'gemini-3.5-flash' &&
        model !== 'gemini-3.5-flash-lite' &&
        model !== 'gemini-3.8-flash'
          ? model
          : 'gemini-3.1-flash-lite',
        'gemini-3.1-flash-lite',
        'gemini-flash-latest',
        'gemini-3.8-flash',
      ];
      // Deduplicate while preserving order
      const modelsToTry = [...new Set(modelCandidates)];

      let responseText = '';
      let usedModel = modelsToTry[0];
      let lastError: any = null;
      let isRateLimit = false;
      let isServiceUnavailable = false;

      for (const m of modelsToTry) {
        try {
          console.log(`[APDM Server] Attempting generation with model ${m}...`);
          const res = await ai.models.generateContent({
            model: m,
            contents: formattedContents,
            config: {
              systemInstruction,
              temperature: 0.7,
              maxOutputTokens: 800,
            },
          });
          if (res.text) {
            responseText = res.text;
            usedModel = m;
            console.log(`[APDM Server] Model ${m} succeeded! Output length: ${responseText.length}`);
            break;
          }
        } catch (e: any) {
          lastError = e;
          const status = e.status || e.statusCode;
          console.log(`[APDM Server] Candidate ${m} returned ${status || e.message}; evaluating fallback.`);
          if (status === 429 || (e.message && e.message.includes('429'))) {
            isRateLimit = true;
            await new Promise((resolve) => setTimeout(resolve, 500));
          } else if (status === 503 || (e.message && e.message.includes('503'))) {
            isServiceUnavailable = true;
            await new Promise((resolve) => setTimeout(resolve, 500));
          }
        }
      }

      if (!responseText) {
        if (isRateLimit) {
          res.status(429).json({
            error:
              'Gemini API rate limit reached (429). Please wait a few seconds and try again, or add a custom Gemini API key in Settings.',
          });
          return;
        }
        if (isServiceUnavailable) {
          res.status(503).json({
            error:
              'The AI companion service is momentarily overloaded (503 Service Unavailable). Please tap Retry in a few moments.',
          });
          return;
        }
        throw lastError || new Error('No candidate model could generate a response.');
      }

      res.status(200).json({
        text: responseText,
        detectedLanguage,
        model: usedModel,
        activeSpeaker,
      });
    } catch (err: any) {
      console.error('[APDM Server] Unhandled error:', err);
      res.status(500).json({
        error: err?.message || 'Internal Server Error during Gemini call',
      });
    }
  });

  // Vite integration
  if (process.env.NODE_ENV !== 'production') {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*all', (_req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`APDM Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer();
