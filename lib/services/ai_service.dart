import '../models/chat_message.dart';
import '../models/language.dart';
import '../models/memory.dart';
import '../models/memorial_profile.dart';
import 'gemini_service.dart';
import 'language_service.dart';

class AiResponseResult {
  final String text;
  final AppLanguage language;
  final String? referencedMemoryTitle;

  const AiResponseResult({
    required this.text,
    required this.language,
    this.referencedMemoryTitle,
  });
}

/// Abstract contract for AI response generation based on preserved memories and language.
abstract class IAiConversationService {
  Future<AiResponseResult> generateMultilingualResponse({
    required String userUtterance,
    required List<Memory> memories,
    required MemorialProfile profile,
    List<ChatMessage>? conversationHistory,
    AppLanguage? forcedLanguage,
  });

  // Legacy helper
  Future<String> generateResponse({
    required String userUtterance,
    required List<Memory> memories,
    required MemorialProfile profile,
  });
}

/// Real AI Conversational Service coordinating Gemini AI, multi-turn history,
/// dynamic memory retrieval, and language matching.
class AiConversationService implements IAiConversationService {
  final IGeminiService _geminiService;
  final ILanguageDetectionService _languageService;

  AiConversationService({
    IGeminiService? geminiService,
    ILanguageDetectionService? languageService,
  })  : _geminiService = geminiService ?? GeminiService(),
        _languageService = languageService ?? LocalLanguageDetector();

  @override
  Future<AiResponseResult> generateMultilingualResponse({
    required String userUtterance,
    required List<Memory> memories,
    required MemorialProfile profile,
    List<ChatMessage>? conversationHistory,
    AppLanguage? forcedLanguage,
  }) async {
    final detectedLanguage = forcedLanguage ?? _languageService.detectLanguage(userUtterance);

    // 1. Retrieve ONLY relevant memories for the current prompt & context
    final relevantMemories = _filterRelevantMemories(
      userUtterance: userUtterance,
      allMemories: memories,
      history: conversationHistory ?? [],
    );

    String? referencedTitle;
    if (relevantMemories.isNotEmpty) {
      referencedTitle = relevantMemories.first.title;
    }

    // 2. Generate contextual response via Gemini / Generative Engine
    final responseText = await _geminiService.generateContent(
      prompt: userUtterance,
      conversationHistory: conversationHistory ?? [],
      relevantMemories: relevantMemories,
      profile: profile,
      detectedLanguage: detectedLanguage,
    );

    return AiResponseResult(
      text: responseText,
      language: detectedLanguage,
      referencedMemoryTitle: referencedTitle,
    );
  }

  /// Dynamic memory filtering: retrieves only relevant memories based on entity & intent
  List<Memory> _filterRelevantMemories({
    required String userUtterance,
    required List<Memory> allMemories,
    required List<ChatMessage> history,
  }) {
    if (allMemories.isEmpty) return [];

    final lower = userUtterance.toLowerCase();
    final List<Memory> matches = [];

    // Check for Meenu / Daughter
    if (lower.contains('meenu') || lower.contains('college') || lower.contains('chellam') || lower.contains('exam') || lower.contains('avakku')) {
      matches.addAll(allMemories.where((m) =>
          m.title.toLowerCase().contains('meenu') ||
          m.content.toLowerCase().contains('meenu')));
    }

    // Check for Dinesh / Son / Business
    if (lower.contains('dinesh') || lower.contains('business') || lower.contains('career') || lower.contains('avanukku') || lower.contains('uzhaipu')) {
      matches.addAll(allMemories.where((m) =>
          m.title.toLowerCase().contains('dinesh') ||
          m.content.toLowerCase().contains('dinesh')));
    }

    // Check for Padma / Wife / Bawa
    if (lower.contains('padma') || lower.contains('bawa') || lower.contains('manaivi') || lower.contains('vendakkai') || lower.contains('poriyal')) {
      matches.addAll(allMemories.where((m) =>
          m.title.toLowerCase().contains('padma') ||
          m.title.toLowerCase().contains('bawa') ||
          m.content.toLowerCase().contains('padma') ||
          m.content.toLowerCase().contains('bawa')));
    }

    // Check for Food / Coffee / Sambar
    if (lower.contains('coffee') || lower.contains('kaapi') || lower.contains('saapa') || lower.contains('sambar') || lower.contains('lunch') || lower.contains('unavu')) {
      matches.addAll(allMemories.where((m) =>
          m.title.toLowerCase().contains('saapaadu') ||
          m.content.toLowerCase().contains('coffee') ||
          m.content.toLowerCase().contains('sambar')));
    }

    // Check for Childhood / Evening Walks
    if (lower.contains('childhood') || lower.contains('walk') || lower.contains('school') || lower.contains('bicycle') || lower.contains('cycle')) {
      matches.addAll(allMemories.where((m) =>
          m.title.toLowerCase().contains('childhood') ||
          m.content.toLowerCase().contains('cycle') ||
          m.content.toLowerCase().contains('walk')));
    }

    // If matches found, return distinct list (up to 3 most relevant)
    if (matches.isNotEmpty) {
      final seen = <String>{};
      return matches.where((m) => seen.add(m.id)).take(3).toList();
    }

    // Default: return top 2 most general family memories
    return allMemories.take(2).toList();
  }

  @override
  Future<String> generateResponse({
    required String userUtterance,
    required List<Memory> memories,
    required MemorialProfile profile,
  }) async {
    final result = await generateMultilingualResponse(
      userUtterance: userUtterance,
      memories: memories,
      profile: profile,
    );
    return result.text;
  }
}

/// Backward compatibility alias
typedef MockAiConversationService = AiConversationService;

