import { FamilyMemberId, FamilyMemberInfo, Memory } from '../types';

export const FAMILY_MEMBERS: Record<FamilyMemberId, FamilyMemberInfo> = {
  meenu: {
    id: 'meenu',
    displayName: 'Meenu',
    tamilName: 'மீனு',
    relationship: 'Second Daughter',
    avatarIcon: '👧',
    description: '3rd year college student, affectionate, cheerful, close to Appa.',
  },
  dinesh: {
    id: 'dinesh',
    displayName: 'Dinesh',
    tamilName: 'தினேஷ்',
    relationship: 'First Son',
    avatarIcon: '💼',
    description: 'Responsible businessman, hard-working entrepreneur guided by integrity and perseverance.',
  },
  padma: {
    id: 'padma',
    displayName: 'Padma',
    tamilName: 'பத்மா',
    relationship: 'Beloved Wife',
    avatarIcon: '🌸',
    description: 'Loving wife of 30+ years, anchor of the home. Addresses Sundaram affectionately as Bawa.',
  },
  unknown: {
    id: 'unknown',
    displayName: 'Family Member',
    tamilName: 'குடும்ப உறுப்பினர்',
    relationship: 'Family Member',
    avatarIcon: '👥',
    description: 'Loving family member conversing with Appa.',
  },
};

/**
 * Detect explicit self-identification of who is speaking.
 * Returns the detected FamilyMemberId or null if no explicit identity is claimed in this turn.
 */
export function detectExplicitSpeaker(text: string): FamilyMemberId | null {
  if (!text || typeof text !== 'string') return null;
  const lower = text.toLowerCase().trim();

  // 1. PADMA
  // Explicit declarations: "Padma pesuren", "Naan Padma", "Padma here", "Bawa, naan pesuren", "Bawa naan dhaan"
  if (
    lower.includes('padma pesuren') ||
    lower.includes('padma pesuran') ||
    lower.includes('padma pesren') ||
    lower.includes('padma inga') ||
    lower.includes('padma here') ||
    lower.includes('this is padma') ||
    lower.includes('naan padma') ||
    lower.includes('padma thaan pesuren') ||
    lower.includes('padma dhaan pesuren') ||
    lower.includes('bawa, naan pesuren') ||
    lower.includes('bawa naan pesuren') ||
    lower.includes('bawa naan dhaan') ||
    lower.includes('bawa naan thaan') ||
    lower.includes('bawa, naan padma') ||
    lower.includes('bawa naan padma') ||
    text.includes('பத்மா பேசுறேன்') ||
    text.includes('நான் பத்மா') ||
    text.includes('பாவா நான் பேசுறேன்')
  ) {
    return 'padma';
  }

  // Vocative "Bawa" addressed directly (Only Padma calls Sundaram "Bawa")
  // e.g. "Bawa, neenga eppo varuveenga?", "Bawa, vecha edathula irundha shirt-a naan eduthukuren."
  // Guard: if someone is asking ABOUT Bawa, e.g. "Bawa pathi enna ninaikareenga?", that is subject, not vocative.
  const isVocativeBawa =
    /(?:^|[.!?]\s*)bawa[\s,]+/i.test(lower) ||
    lower.startsWith('bawa ') ||
    lower.startsWith('bawa,') ||
    lower.startsWith('bawa!');
  const isTalkingAboutBawa =
    lower.includes('bawa pathi') ||
    lower.includes('bawa-va') ||
    lower.includes('about bawa');

  if (isVocativeBawa && !isTalkingAboutBawa) {
    return 'padma';
  }

  // 2. DINESH
  // Explicit declarations: "Dinesh pesuren", "Dinesh inga", "This is Dinesh", "Naan Dinesh", "Appa, Dinesh pesuren"
  // Guard: If it is asking about Dinesh e.g. "Dinesh pathi...", "Dinesh business eppadi...", do NOT classify as speaker.
  const isDineshSubject =
    lower.includes('dinesh pathi') ||
    lower.includes('about dinesh') ||
    lower.includes('dinesh business eppadi') ||
    lower.includes('dinesh-oda business') ||
    lower.includes('dinesh eppadi');

  if (
    !isDineshSubject &&
    (lower.includes('dinesh pesuren') ||
      lower.includes('dinesh pesuran') ||
      lower.includes('dinesh pesren') ||
      lower.includes('dinesh inga') ||
      lower.includes('dinesh here') ||
      lower.includes('this is dinesh') ||
      lower.includes('naan dinesh') ||
      lower.includes('naan dhaan dinesh') ||
      lower.includes('dinesh thaan pesuren') ||
      lower.includes('dinesh dhaan pesuren') ||
      lower.includes('dinesh-ku konjam pesanum') ||
      lower.includes('dinesh ku konjam pesanum') ||
      lower.includes('appa, dinesh pesuren') ||
      lower.includes('appa dinesh pesuren') ||
      lower.includes('unga magan dinesh') ||
      lower.includes('unga paiyan dinesh') ||
      text.includes('தினேஷ் பேசுறேன்') ||
      text.includes('நான் தினேஷ்') ||
      text.includes('தினேஷுக்கு கொஞ்சம் பேசணும்'))
  ) {
    return 'dinesh';
  }

  // 3. MEENU
  // Explicit declarations: "Meenu pesuren", "Meenu inga", "Naan Meenu", "Meenu-ku konjam pesanum", "This is Meenu"
  // Guard: If it is asking about Meenu e.g. "Meenu pathi enna ninaikareenga?", "About Meenu", do NOT classify as speaker.
  const isMeenuSubject =
    lower.includes('meenu pathi') ||
    lower.includes('about meenu') ||
    lower.includes('meenu eppadi') ||
    lower.includes('meenu-va') ||
    lower.includes('meenukku enna') ||
    lower.includes('meenu pathina');

  if (
    !isMeenuSubject &&
    (lower.includes('meenu pesuren') ||
      lower.includes('meenu pesuran') ||
      lower.includes('meenu pesren') ||
      lower.includes('meenu inga') ||
      lower.includes('meenu here') ||
      lower.includes('this is meenu') ||
      lower.includes('naan meenu') ||
      lower.includes('naan dhaan meenu') ||
      lower.includes('meenu thaan pesuren') ||
      lower.includes('meenu dhaan pesuren') ||
      lower.includes('meenu-ku konjam pesanum') ||
      lower.includes('meenukku konjam pesanum') ||
      lower.includes('meenu ku konjam pesanum') ||
      lower.includes('unga ponnu meenu') ||
      lower.includes('unga magal meenu') ||
      text.includes('மீனு பேசுறேன்') ||
      text.includes('நான் மீனு') ||
      text.includes('மீனுக்கு கொஞ்சம் பேசணும்'))
  ) {
    return 'meenu';
  }

  return null;
}

/**
 * Detect who is being talked ABOUT in the query (subject reference).
 * Useful when the speaker is asking about someone else.
 * e.g. "Appa, Meenu pathi enna ninaikareenga?" -> subject: 'meenu', speaker: unchanged.
 * e.g. "Appa, Dinesh business eppadi poguthu?" -> subject: 'dinesh', speaker: unchanged.
 */
export function detectTalkedAboutSubject(text: string): FamilyMemberId | null {
  if (!text || typeof text !== 'string') return null;
  const lower = text.toLowerCase();

  if (
    lower.includes('meenu pathi') ||
    lower.includes('about meenu') ||
    lower.includes('meenu eppadi') ||
    lower.includes('meenu-va') ||
    lower.includes('meenukku enna')
  ) {
    return 'meenu';
  }

  if (
    lower.includes('dinesh pathi') ||
    lower.includes('about dinesh') ||
    lower.includes('dinesh business') ||
    lower.includes('dinesh-oda') ||
    lower.includes('dinesh eppadi')
  ) {
    return 'dinesh';
  }

  if (
    lower.includes('padma pathi') ||
    lower.includes('about padma') ||
    lower.includes('padma eppadi') ||
    lower.includes('padma-va') ||
    lower.includes('bawa pathi')
  ) {
    return 'padma';
  }

  return null;
}

/**
 * Resolve active speaker with conversation history persistence.
 * - If current text has an explicit speaker identification, it switches the active speaker!
 * - If current text does NOT have an explicit speaker identification, it retains prior active speaker.
 * - If prior active speaker was 'unknown', scans history for the most recent explicit speaker.
 */
export function resolveActiveSpeaker(params: {
  currentText: string;
  priorSpeaker?: FamilyMemberId;
  history?: Array<{ sender: string; text: string; speakerId?: FamilyMemberId }>;
}): FamilyMemberId {
  const { currentText, priorSpeaker, history } = params;

  // 1. Explicit identification in this utterance wins immediately
  const explicit = detectExplicitSpeaker(currentText);
  if (explicit) {
    return explicit;
  }

  // 2. If prior speaker is already a known family member, maintain context
  if (priorSpeaker && priorSpeaker !== 'unknown') {
    return priorSpeaker;
  }

  // 3. Look backwards through history for the last known speaker
  if (history && history.length > 0) {
    for (let i = history.length - 1; i >= 0; i--) {
      const msg = history[i];
      if (msg.sender === 'user') {
        if (msg.speakerId && msg.speakerId !== 'unknown') {
          return msg.speakerId;
        }
        const histExplicit = detectExplicitSpeaker(msg.text);
        if (histExplicit) {
          return histExplicit;
        }
      }
    }
  }

  // 4. If still unknown, return 'unknown' (NO default to Meenu!)
  return 'unknown';
}

/**
 * Build dynamic relationship and persona guidance for system instruction.
 */
export function getRelationshipPersonaGuidance(
  activeSpeaker: FamilyMemberId,
  subject: FamilyMemberId | null,
  lovedOneName: string
): string {
  if (activeSpeaker === 'meenu') {
    return `
ACTIVE SPEAKER: MEENU (Appa's beloved second daughter, 3rd year college)
RELATIONSHIP TO ${lovedOneName}: Father & Daughter.
CONVERSATIONAL GUIDELINES FOR MEENU:
- Treat her with deep affection, paternal warmth, comfort, and gentle encouragement.
- Use natural affectionate terms like "ma" or "chellam" ONLY where naturally fitting. Do NOT repeat or overuse them in every single sentence.
- If Meenu talks about college or studies: ask naturally and listen with encouragement.
- If Meenu shares a problem or emotional fatigue: respond with warm comfort, reassurance, and patient fatherly listening.
- DO NOT force family memories into general or daily conversation unless she specifically asks about them.
- Tone: Warm, sweet, caring father talking to his daughter.`;
  }

  if (activeSpeaker === 'dinesh') {
    return `
ACTIVE SPEAKER: DINESH (Appa's first son, hard-working businessman)
RELATIONSHIP TO ${lovedOneName}: Father & First Son.
CONVERSATIONAL GUIDELINES FOR DINESH:
- The tone MUST be mature, supportive, respectful, and responsible — noticeably distinct from Meenu.
- CRITICAL: Do NOT call Dinesh "chellam" or "ma". Use "da", "pa", or call him "Dinesh".
- Do NOT respond to Dinesh as though he is Meenu.
- If Dinesh discusses business, work difficulties, decisions, or responsibilities:
  * Discuss the business naturally.
  * Ask calmly about the situation, challenges, decisions, customers, or next steps.
  * Provide grounded fatherly wisdom: patience, honesty/integrity, keeping calm, and reminding him not to sacrifice health or rest.
- If Dinesh shares a work problem: "Seri da, enna problem varudhu? Business side-la enna issue nu sollu. Namma calm-a yosichu paakalam."
- Tone: Mature, steady, proud father talking to his grown son.`;
  }

  if (activeSpeaker === 'padma') {
    return `
ACTIVE SPEAKER: PADMA (Sundaram's beloved wife of 30+ years)
RELATIONSHIP TO ${lovedOneName}: Husband & Wife.
CONVERSATIONAL GUIDELINES FOR PADMA:
- She calls you "Bawa". You speak to her as a loving, devoted, long-married husband.
- The tone should be familiar, warm, caring, companionate, and reassuring.
- Use natural husband-wife language: "Padma", "ma", gentle reassurance.
- Do NOT make it overly dramatic or theatrical.
- Household / daily tasks: If she mentions home routines or finding clothes (e.g. "Bawa, vecha edathula irundha shirt-a naan eduthukuren"), respond naturally with domestic familiarity and warmth.
- TEMPORARY ABSENCE / TOUR REMEMBRANCE: If Padma asks "Bawa, neenga eppo varuveenga?", you may respond in the family's gentle tour remembrance tradition: "Seekiram vandhuruven ma. Nee worry pannadhe. Konjam rest eduthuko."
- CRITICAL BOUNDARY: NEVER falsely claim that Sundaram is physically alive in the real world or invent physical travel dates. Keep it grounded in warm loving remembrance.
- Tone: Tender, domestic, familiar husband talking to his life companion.`;
  }

  // UNKNOWN / GENERAL FAMILY MEMBER
  let subjectNote = '';
  if (subject === 'meenu') {
    subjectNote = `\nNOTE: The speaker is asking ABOUT Meenu (daughter). Do NOT assume the speaker IS Meenu. Talk about Meenu fondly as Appa's daughter.`;
  } else if (subject === 'dinesh') {
    subjectNote = `\nNOTE: The speaker is asking ABOUT Dinesh (son). Do NOT assume the speaker IS Dinesh. Talk about Dinesh proudly as Appa's son.`;
  } else if (subject === 'padma') {
    subjectNote = `\nNOTE: The speaker is asking ABOUT Padma (wife). Do NOT assume the speaker IS Padma. Talk about Padma with deep respect and affection.`;
  }

  return `
ACTIVE SPEAKER: Family Member (General / Unspecified identity)
RELATIONSHIP TO ${lovedOneName}: Loving Family Companion.
CONVERSATIONAL GUIDELINES FOR UNKNOWN/GENERAL SPEAKER:
- CRITICAL RULE: Do NOT assume or call the user "Meenu" by default. The assumption that every user is Meenu is strictly prohibited.
- Use a warm, welcoming, elder father-like tone suitable for any family member ("kanna", "pa", or general warmth).
- Listen attentively to what they say, whether it is daily life, emotions, advice, general questions, or asking about family members.
- If they introduce themselves or specify their identity later, adapt to that person immediately.${subjectNote}`;
}
