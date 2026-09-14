import { AppLanguage } from '../types';

const TAMIL_SCRIPT_REGEX = /[\u0B80-\u0BFF]/;

// High-confidence Tamil/Tanglish grammatical markers, verbs, suffixes, and particles
const TANGLISH_MARKERS = new Set([
  'eppadi', 'epdi', 'irukkeenga', 'irukinga', 'irukku', 'iruken', 'irukken', 'irukanga', 'irukkom', 'irundha',
  'pesunga', 'pesalama', 'pesu', 'pesanum', 'pesanam', 'pesaren', 'pesuvom', 'pathi', 'pathina', 'pathiya',
  'enakku', 'enaku', 'unaku', 'unakku', 'ungalukku', 'ennoda', 'unga', 'ungala', 'avanukku', 'avalukku', 'avakku',
  'romba', 'kashtam', 'kashtama', 'kashtamaa', 'nalla', 'nallaa', 'enna', 'ethu', 'edhu',
  'sollu', 'solunga', 'solren', 'solla', 'theriyuma', 'puriyala', 'puriyuthu', 'vaanga', 'ponga',
  'saapda', 'saaptacha', 'saaptiya', 'saapten', 'saapaadu', 'saapudunga', 'aachu', 'aachi', 'kuzhappam', 'ninaivugal', 'nyabagam',
  'innikku', 'innaiku', 'naalaikku', 'kooda', 'mattum', 'aana', 'illai', 'illa',
  'kavala', 'kavalapadathinga', 'valikuthu', 'poriyal', 'vendakkai', 'samayal',
  'chellam', 'chello', 'kanna', 'kannu', 'bawa', 'manaivi', 'uzhaipu', 'porumai', 'thairiyam', 'dhairiyam',
  'kitta', 'konjam', 'poguthu', 'senja', 'irukka', 'irukkaa', 'vazhkai', 'amaidhi',
  'thatha', 'paati', 'thambi', 'thangachi', 'marakka', 'mudiyala', 'azhuga', 'santhosham',
  'manasu', 'manasula', 'kaapi', 'kudika', 'kudipingala', 'kudicha', 'kadhai', 'kadhaigal',
  'seri', 'aprom', 'appuram', 'aasirvaadham', 'nambikkai',
  'oru', 'panradhu', 'panna', 'pannunga', 'panrathu', 'panren', 'venum', 'venuma',
  'nu', 'than', 'dhaan', 'thambi', 'akkaa', 'amma', 'appa', 'parava', 'paravalla', 'paathukalam',
  'vandha', 'vandhuten', 'poiten', 'kekren', 'kekkaren', 'kekiren', 'kekkareengala', 'keppeenga',
  'naan', 'naanum', 'nee', 'neenga', 'namma', 'namakku', 'inga', 'anga', 'engae', 'enga',
  'ma', 'pa', 'da', 'di'
]);

// Structural English words to properly classify sentences
const ENGLISH_STRUCTURAL_WORDS = new Set([
  'how', 'are', 'you', 'today', 'is', 'was', 'were', 'the', 'a', 'an',
  'can', 'could', 'would', 'should', 'tell', 'me', 'about', 'what', 'where',
  'when', 'why', 'who', 'which', 'do', 'did', 'does', 'have', 'has', 'had',
  'feel', 'feeling', 'doing', 'hello', 'hi', 'morning', 'evening', 'night',
  'please', 'thanks', 'thank', 'talk', 'business', 'remember', 'memory', 'college',
  'fine', 'good', 'great', 'miss', 'family', 'explain', 'understand', 'think',
  'advice', 'problem', 'actually', 'doubt', 'day', 'really', 'something', 'life',
  'ai', 'help', 'need', 'want', 'work', 'study', 'tired'
]);

export function detectLanguage(text: string): AppLanguage {
  if (!text || text.trim().length === 0) return 'english';

  // 1. Check for native Tamil script Unicode block
  if (TAMIL_SCRIPT_REGEX.test(text)) {
    return 'tamil';
  }

  // 2. Tokenize lowercase words
  const clean = text.toLowerCase().replace(/[^a-z0-9\s-]/g, ' ');
  const words = clean.split(/\s+/).filter(Boolean);

  let tanglishScore = 0;
  let englishScore = 0;

  for (const rawWord of words) {
    const word = rawWord.replace(/^[-\s]+|[-\s]+$/g, '');
    if (TANGLISH_MARKERS.has(word)) {
      tanglishScore += 2;
    } else if (ENGLISH_STRUCTURAL_WORDS.has(word)) {
      englishScore += 1;
    } else if (
      word.endsWith('nga') ||
      word.endsWith('laam') ||
      word.endsWith('-la') ||
      word.endsWith('la') ||
      word.endsWith('-ku') ||
      word.endsWith('ku') ||
      word.endsWith('chu') ||
      word.endsWith('thu') ||
      word.endsWith('-a') ||
      word.endsWith('ala')
    ) {
      tanglishScore += 1;
    }
  }

  // Clear winner
  if (tanglishScore > englishScore) {
    return 'tanglish';
  }
  if (englishScore > tanglishScore) {
    return 'english';
  }
  // Tied or zero
  return tanglishScore > 0 ? 'tanglish' : 'english';
}

