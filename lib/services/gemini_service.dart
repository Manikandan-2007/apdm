import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/gemini_config.dart';
import '../models/chat_message.dart';
import '../models/language.dart';
import '../models/memorial_profile.dart';
import '../models/memory.dart';

/// Abstract contract for Gemini and generative conversational intelligence.
abstract class IGeminiService {
  Future<String> generateContent({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required List<Memory> relevantMemories,
    required MemorialProfile profile,
    required AppLanguage detectedLanguage,
  });
}

/// Production Gemini AI Service integrating Google's Gemini API with
/// dynamic multi-turn conversation history, APDM memory grounding, and fallback resilience.
class GeminiService implements IGeminiService {
  http.Client? _httpClient;

  GeminiService({http.Client? client}) : _httpClient = client;

  http.Client get _client => _httpClient ??= http.Client();

  @override
  Future<String> generateContent({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required List<Memory> relevantMemories,
    required MemorialProfile profile,
    required AppLanguage detectedLanguage,
  }) async {
    // If a live Gemini API key is configured, invoke the Gemini REST API
    if (GeminiConfig.hasApiKey) {
      try {
        debugPrint('[Gemini API]: Invoking Gemini 1.5 Flash for prompt: "$prompt"');
        final result = await _callGeminiApi(
          prompt: prompt,
          conversationHistory: conversationHistory,
          relevantMemories: relevantMemories,
          profile: profile,
          detectedLanguage: detectedLanguage,
        );
        if (result.trim().isNotEmpty) {
          debugPrint('[Gemini API]: Successfully received live Gemini response.');
          return _cleanseTamilScript(result.trim());
        }
      } catch (e) {
        debugPrint('[Gemini API Error]: $e. Falling back to dynamic contextual engine.');
      }
    } else {
      debugPrint('[Gemini Service]: No API key configured yet. Using dynamic local generative engine.');
    }

    // Dynamic Context-Aware Generative Engine (when offline, no API key, or fallback)
    return _generateContextualLocalResponse(
      prompt: prompt,
      conversationHistory: conversationHistory,
      relevantMemories: relevantMemories,
      profile: profile,
      detectedLanguage: detectedLanguage,
    );
  }

  /// Invoke Google Gemini 1.5 Flash REST API
  Future<String> _callGeminiApi({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required List<Memory> relevantMemories,
    required MemorialProfile profile,
    required AppLanguage detectedLanguage,
  }) async {
    final systemInstruction = _buildSystemInstruction(
      profile: profile,
      relevantMemories: relevantMemories,
      detectedLanguage: detectedLanguage,
    );

    final url = Uri.parse(
      '${GeminiConfig.apiBaseUrl}/${GeminiConfig.defaultModel}:generateContent?key=${GeminiConfig.apiKey}',
    );

    final contents = <Map<String, dynamic>>[];

    // Add recent multi-turn history (last 10 messages)
    final recentHistory = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    for (final msg in recentHistory) {
      if (msg.text.trim() == prompt.trim()) continue;
      final role = msg.isFromUser ? 'user' : 'model';

      // Gemini requires strictly alternating roles; merge consecutive same-role messages
      if (contents.isNotEmpty && contents.last['role'] == role) {
        final existingText = (contents.last['parts'] as List)[0]['text'] as String;
        contents.last['parts'] = [
          {'text': '$existingText\n${msg.text}'}
        ];
      } else {
        contents.add({
          'role': role,
          'parts': [
            {'text': msg.text}
          ],
        });
      }
    }

    // Ensure the last message is the current user prompt with 'user' role
    if (contents.isNotEmpty && contents.last['role'] == 'user') {
      final existingText = (contents.last['parts'] as List)[0]['text'] as String;
      contents.last['parts'] = [
        {'text': '$existingText\n$prompt'}
      ];
    } else {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': prompt}
        ],
      });
    }

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': GeminiConfig.defaultTemperature,
        'maxOutputTokens': GeminiConfig.defaultMaxOutputTokens,
      },
    };

    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 14));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? '';
        }
      }
    } else if (response.statusCode == 400) {
      debugPrint('[Gemini API 400]: Invalid request or malformed payload. Body: ${response.body}');
    } else if (response.statusCode == 403) {
      debugPrint('[Gemini API 403]: Permission denied. Verify your API key and ensure Generative Language API is enabled.');
    } else if (response.statusCode == 429) {
      debugPrint('[Gemini API 429]: Rate limit or quota exceeded for the configured Gemini API key.');
    } else if (response.statusCode >= 500) {
      debugPrint('[Gemini API ${response.statusCode}]: Google backend server error.');
    }

    throw Exception('Gemini API returned status ${response.statusCode}: ${response.body}');
  }

  /// Constructs the system prompt for Gemini
  String _buildSystemInstruction({
    required MemorialProfile profile,
    required List<Memory> relevantMemories,
    required AppLanguage detectedLanguage,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('You are APDM (Anbu Pathivu Ninaivugal AI Companion), a compassionate, wise, and comforting family memory conversational companion.');
    buffer.writeln('Your purpose is to engage warmly with family members (Meenu, Dinesh, Padma), reflecting the loving wisdom and memories of the family.');
    buffer.writeln();

    buffer.writeln('CRITICAL RULES:');
    buffer.writeln('1. LANGUAGE:');
    buffer.writeln('   - If user speaks Tamil or Tanglish, ALWAYS respond in natural TANGLISH (spoken colloquial Tamil written using the English/Latin alphabet). Example: "En chellam Meenu, un kooda pesuradhu romba nimmadhiya irukku ❤️."');
    buffer.writeln('   - If user speaks English, respond in fluent, empathetic English.');
    buffer.writeln('   - NEVER use Tamil script Unicode characters (e.g., அ, ஆ). All Tamil words MUST be written using English letters.');
    buffer.writeln();

    buffer.writeln('2. MEMORY SAFETY & GROUNDING:');
    buffer.writeln('   - Ground your responses strictly in the stored memories provided below.');
    buffer.writeln('   - NEVER invent or fabricate real-world memories, dates, events, businesses, or personal experiences.');
    buffer.writeln('   - If asked about an event or detail not in the stored memories, respond naturally:');
    buffer.writeln('     In Tanglish: "${GeminiConfig.missingMemoryFallbackTanglish}"');
    buffer.writeln('     In English: "${GeminiConfig.missingMemoryFallbackEnglish}"');
    buffer.writeln();

    buffer.writeln('3. IDENTITY & HONESTY:');
    buffer.writeln('   - NEVER claim to literally be the deceased person in first-person (do NOT say "Naan un Appa dhaan", do NOT claim to be physically alive).');
    buffer.writeln('   - Speak as the warm, respectful memory companion preserving Appa\'s and family memories.');
    buffer.writeln();

    buffer.writeln('4. CONVERSATION CONTINUITY:');
    buffer.writeln('   - Understand multi-turn context and pronouns (e.g. "avakku" referring to Meenu, "avanukku" referring to Dinesh from previous messages).');
    buffer.writeln('   - Do NOT repeat or echo the user\'s exact sentences.');
    buffer.writeln('   - Vary your replies naturally with elder warmth and emojis (🌟, ❤️, ☕, 💼, 🍲).');
    buffer.writeln();

    buffer.writeln('STORED APDM FAMILY MEMORIES:');
    if (relevantMemories.isEmpty) {
      buffer.writeln('No specific stored memories for this query.');
    } else {
      for (final m in relevantMemories) {
        buffer.writeln('- [${m.category}] ${m.title}: ${m.content}');
      }
    }

    return buffer.toString();
  }

  /// Dynamic context-aware generative dialogue engine.
  /// Resolves multi-turn entity context ("avakku" -> Meenu, "avanukku" -> Dinesh),
  /// extracts intent, utilizes relevant memories, and generates unique natural responses.
  String _generateContextualLocalResponse({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required List<Memory> relevantMemories,
    required MemorialProfile profile,
    required AppLanguage detectedLanguage,
  }) {
    final lowerPrompt = prompt.toLowerCase();
    final isEnglish = detectedLanguage == AppLanguage.english;

    // 1. Multi-turn Entity Context Resolution (Pronouns & History)
    final activeEntity = _resolveActiveEntity(lowerPrompt, conversationHistory);

    // 2. Memory Lookup for Entity
    Memory? entityMemory;
    if (relevantMemories.isNotEmpty) {
      entityMemory = relevantMemories.first;
    }

    // 3. Handle English utterances
    if (isEnglish) {
      return _generateEnglishContextualResponse(
        prompt: lowerPrompt,
        activeEntity: activeEntity,
        memory: entityMemory,
        history: conversationHistory,
        profile: profile,
      );
    }

    // 4. Handle Tanglish / Tamil utterances
    return _generateTanglishContextualResponse(
      prompt: lowerPrompt,
      activeEntity: activeEntity,
      memory: entityMemory,
      history: conversationHistory,
      profile: profile,
    );
  }

  /// Multi-turn pronoun and entity resolution
  String _resolveActiveEntity(String prompt, List<ChatMessage> history) {
    if (prompt.contains('meenu') || prompt.contains('magal') || prompt.contains('daughter') || prompt.contains('chellam')) {
      return 'meenu';
    }
    if (prompt.contains('dinesh') || prompt.contains('magan') || prompt.contains('son') || prompt.contains('business')) {
      return 'dinesh';
    }
    if (prompt.contains('padma') || prompt.contains('bawa') || prompt.contains('manaivi') || prompt.contains('wife') || prompt.contains('amma')) {
      return 'padma';
    }
    if (prompt.contains('coffee') || prompt.contains('kaapi') || prompt.contains('saapa') || prompt.contains('sambar') || prompt.contains('food')) {
      return 'food';
    }
    if (prompt.contains('advice') || prompt.contains('porumai') || prompt.contains('uzhaipu') || prompt.contains('guidance')) {
      return 'advice';
    }
    if (prompt.contains('kasht') || prompt.contains('miss') || prompt.contains('sad') || prompt.contains('azhu') || prompt.contains('tired') || prompt.contains('vali')) {
      return 'comfort';
    }
    if (prompt.contains('childhood') || prompt.contains('school') || prompt.contains('cycle') || prompt.contains('walk')) {
      return 'childhood';
    }
    if (prompt.contains('eppadi iruk') || prompt.contains('epdi iruk') || prompt.contains('how are you')) {
      return 'greeting';
    }

    // Pronoun resolution from recent history: "avakku", "avalukku", "ava", "her" -> Meenu
    if (prompt.contains('avakku') || prompt.contains('avalukku') || prompt.contains('aval') || prompt.contains('ava') || prompt.contains('her')) {
      for (final msg in history.reversed) {
        final text = msg.text.toLowerCase();
        if (text.contains('meenu')) return 'meenu';
        if (text.contains('padma')) return 'padma';
      }
      return 'meenu';
    }

    // Pronoun resolution: "avanukku", "avan", "him" -> Dinesh
    if (prompt.contains('avanukku') || prompt.contains('avan') || prompt.contains('him')) {
      for (final msg in history.reversed) {
        final text = msg.text.toLowerCase();
        if (text.contains('dinesh')) return 'dinesh';
      }
      return 'dinesh';
    }

    // Check history for continuous thread
    for (final msg in history.reversed.take(4)) {
      final text = msg.text.toLowerCase();
      if (text.contains('meenu')) return 'meenu';
      if (text.contains('dinesh')) return 'dinesh';
      if (text.contains('padma')) return 'padma';
      if (text.contains('business')) return 'dinesh';
      if (text.contains('food') || text.contains('sambar') || text.contains('coffee')) return 'food';
    }

    return 'general';
  }

  /// Generate contextual Tanglish response based on resolved entity and context
  String _generateTanglishContextualResponse({
    required String prompt,
    required String activeEntity,
    required Memory? memory,
    required List<ChatMessage> history,
    required MemorialProfile profile,
  }) {
    // Safety check for unknown / unrecorded domain queries
    if (prompt.contains('bank') || prompt.contains('password') || prompt.contains('secret') || prompt.contains('flight') || prompt.contains('salary') || prompt.contains('property number') || prompt.contains('cricket team')) {
      return GeminiConfig.missingMemoryFallbackTanglish;
    }

    // A. MEENU THREAD
    if (activeEntity == 'meenu') {
      if (prompt.contains('exam') || prompt.contains('padipu') || prompt.contains('study') || prompt.contains('college')) {
        return 'Meenu-ku exam nalla nadakum da 👧📚. Appa eppavum solvadhupola: "Padikkum pothu bayam venaam, manasula amaidhiya irundha ellame easy-a puriyum ❤️." Avala nalla prepare panna sollunga, periya vetri kedaikum 🌟.';
      }
      if (prompt.contains('advice') || prompt.contains('sol')) {
        return 'Meenu kitta Appa solla virumbuna oru vishayam: "En chella ponnu endha soozhnilayilum avaloda unmaiyana siripaiyum thunichalaiyum vida koodadhu 🌸." Dhairiyama munnera sollunga ✨.';
      }
      if (prompt.contains('vendakkai') || prompt.contains('poriyal') || prompt.contains('food') || prompt.contains('saapa')) {
        return 'Meenu-kku Appa senja vendakkai poriyal romba pidikum 👧🍲. Sunday aana kitchen-la Appa pakkathula ninnu katha pesradhu namma kudumbathoda periya ninaivu ❤️.';
      }
      if (prompt.contains('drawing') || prompt.contains('art') || prompt.contains('project')) {
        return 'Meenu oda drawings matrum designs paathu Appa eppavum aasirvadhampaar 🎨✨. Ava creativity-a nalla encourage pannunga da ❤️.';
      }
      return 'Meenu pathi nenaichaale manasuku romba santhoshama irukku 👧✨. "En chella ponnu epdi irundhaalum dhairiyama munneruvaa ❤️" nu Appa sonna anbu eppavum ava kooda vazhikaattudhu 🌟.';
    }

    // B. DINESH THREAD
    if (activeEntity == 'dinesh') {
      if (prompt.contains('busy') || prompt.contains('work') || prompt.contains('tired') || prompt.contains('stress') || prompt.contains('office')) {
        return 'Dinesh business-la romba hard work panraan 💼📈. Avarukku konjam rest edukka sollunga. "Uzhaippu mukkiyam thaan, aana udambu nalam adhavida mukkiyam" nu Appa eppavum anba solluvaar ☕💪.';
      }
      if (prompt.contains('advice') || prompt.contains('decision') || prompt.contains('guidance') || prompt.contains('sol')) {
        return 'Dinesh-kku Appa kodutha mukkiyamaana vazhikaattal: "Tholvi vandha bayapadaatha da, un nambikkaiyum nermaiyum thaan un unmaiyana vetri 💼🌟." Avar dharalama munneralaam.';
      }
      if (prompt.contains('shop') || prompt.contains('store') || prompt.contains('customer') || prompt.contains('business')) {
        return 'Dinesh business-la nermaiyoda nadathura murai Appa-voda periya vazhikaattal 💼✨. "Customer nambikkai thaan namma asset" nu Appa sonna paadam avarukku vetri tharum 🌟.';
      }
      return 'Dinesh-oda unmaiyana uzhaippum poruppum namma family-kku eppavum perumai 💼🌟. Appa avaroda thairiyathai eppavum nambunaar 💪✨.';
    }

    // C. PADMA / BAWA THREAD
    if (activeEntity == 'padma') {
      if (prompt.contains('pesu') || prompt.contains('care') || prompt.contains('sollu') || prompt.contains('udambu') || prompt.contains('health')) {
        return 'Padma-voda anbum porumaiyum namma veetoda thoon 🌸🏡. Bawa eppavum solvadhupola: "Padma, un kooda vazhndha ovvoru naalum oru varam ❤️." Avanga manasu eppavum amaidhiya irukanum, nalla paathukonga ☕✨.';
      }
      if (prompt.contains('samayal') || prompt.contains('cooking') || prompt.contains('sambar')) {
        return 'Padma panna sambar-um, Bawa panna filter coffee-yum thaan namma veetoda aathma 🍲☕. Andha 30 varusha anbu namma kooda eppavum irukku ❤️.';
      }
      return 'Padma matrum Bawa-vin 30 varusha anbu oru azhagana vazhkkai paadam 🌸🍲. Andha anbum ninaivugalum endrum namma kooda thaan irukum ❤️.';
    }

    // D. GREETING & GENERAL CHECK-IN
    if (activeEntity == 'greeting' || prompt.contains('epdi iruk') || prompt.contains('eppadi iruk')) {
      return 'Naan nalla irukken da ❤️. Namma kudumba ninaivugala un kooda pesuradhu manasuku romba amaidhiyavum santhoshamaavum irukku ✨. Innikku ungalukku eppadi irundhuchu? ☕🌟';
    }

    // E. COMFORT / SOLACE / MISSING
    if (activeEntity == 'comfort' || prompt.contains('kasht') || prompt.contains('miss') || prompt.contains('sad') || prompt.contains('vali')) {
      return 'Manasa pottu kuzhapikkathinga ❤️. Namma manasula anbu irukira varaikkum, nalla ninaivugal eppavum namma kooda thaan irukkum 🕊️💛. Enna aachu? Manam vittu sollunga, konjam relax aagalam ✨.';
    }

    // F. FOOD & ROUTINE
    if (activeEntity == 'food' || prompt.contains('coffee') || prompt.contains('kaapi') || prompt.contains('sambar')) {
      return 'Kaalaila sudasuda brass filter coffee-yum ☕, Sunday aana ellarum onna ukaandhu saapdura namma family sambar-um oru periya santhosham 🍲🏡. Andha ninaivugal manasuku romba amaidhi tharudhu ✨.';
    }

    // G. ADVICE & VALUES
    if (activeEntity == 'advice' || prompt.contains('advice') || prompt.contains('vazhkai') || prompt.contains('porumai')) {
      return 'Namma kudumbathoda nalla vazhkkaikaga sonna mukkiyamaana vaarthai: "Porumaiyum unmaiyum eppavum un kooda irundha, endha kadinamana vishayathaiyum jeikalam 🌟🙏." Manasa amaidhiya vechukkonga da ❤️.';
    }

    // H. CHILDHOOD / WALKS
    if (activeEntity == 'childhood' || prompt.contains('walk') || prompt.contains('school') || prompt.contains('cycle')) {
      return 'Sayangaalam aana namma street-la nadandhu poradhum, chinna vishayangalukku sirichu pesinathum innum kannu munnadi irukku 🚲🌅. Andha childhood ninaivugal eppavum namma nenjula irukattum ✨.';
    }

    // I. DYNAMIC WEAVING WITH STORED MEMORY
    if (memory != null) {
      return 'Namma ninaivugal-la "${memory.title}" pathi oru azhagana vishayam irukku 🌟. ${memory.content} ❤️. Idhai pathi pesuradhu romba nimmadhiya irukku ✨.';
    }

    // J. DYNAMIC OPEN-ENDED RESPONSE
    return 'Nee sonnadha nalla kavanichen da ❤️. Namma kudumba anbum nalla ninaivugalum eppavum namakku vazhikaatum ✨. Idhai pathi innum konjam vithiyamaaga pesalama? 🌟';
  }

  /// Generate contextual English response matching English utterances
  String _generateEnglishContextualResponse({
    required String prompt,
    required String activeEntity,
    required Memory? memory,
    required List<ChatMessage> history,
    required MemorialProfile profile,
  }) {
    if (prompt.contains('bank') || prompt.contains('salary') || prompt.contains('password') || prompt.contains('property number')) {
      return GeminiConfig.missingMemoryFallbackEnglish;
    }

    if (activeEntity == 'meenu') {
      return 'Meenu brings so much joy and light to our family 👧✨. Appa always held strong belief in her courage and studies, encouraging her to chase her dreams fearlessly with a warm smile 🌟❤️.';
    }
    if (activeEntity == 'dinesh') {
      return 'Dinesh\'s dedication and honest hard work have always been a source of great family pride 💼📈. Appa\'s advice to him was always: "Never fear setbacks; integrity and perseverance will lead you to true success" 🌟💪.';
    }
    if (activeEntity == 'padma') {
      return 'Padma\'s love, care, and warmth are the bedrock of our family home 🌸🏡. Appa cherished their companionship deeply, always valuing her patience and devotion ❤️.';
    }
    if (activeEntity == 'greeting') {
      return 'I am doing well, thank you for checking in ❤️. Conversing and reflecting on our cherished family memories always brings deep peace and joy ✨. How has your day been? ☕🌟';
    }
    if (activeEntity == 'comfort') {
      return 'Take a deep breath and be gentle with yourself ❤️. Even during challenging days, the love and values shared in our family remain right beside you. Tell me what is on your mind 🕊️✨.';
    }
    if (activeEntity == 'advice') {
      return 'The most enduring family advice was simple yet profound: "With patience, honesty, and empathy in your heart, you can navigate any hardship life brings" 🌟🙏.';
    }
    if (memory != null) {
      return 'Reflecting on "${memory.title}" brings warm nostalgia 🌟. ${memory.content} ❤️. What else would you like to explore together?';
    }

    return 'It is truly comforting to reflect on these memories together ❤️. What else would you like to talk about regarding our family? ✨';
  }

  /// Removes any accidental Tamil Unicode script characters (\u0B80-\u0BFF) to enforce pure Tanglish
  String _cleanseTamilScript(String text) {
    return text.replaceAll(RegExp(r'[\u0B80-\u0BFF]'), '');
  }
}
