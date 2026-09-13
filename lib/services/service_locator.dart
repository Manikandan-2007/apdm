import 'gemini_service.dart';
import 'stt_service.dart';
import 'ai_service.dart';
import 'tts_service.dart';
import 'memory_service.dart';
import 'conversation_service.dart';
import 'profile_service.dart';
import 'language_service.dart';
import 'suggestion_service.dart';
import '../core/theme/theme_provider.dart';

/// Lightweight dependency container providing access to APDM services.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  final IGeminiService geminiService = GeminiService();
  final ILanguageDetectionService languageService = LocalLanguageDetector();
  late final IAiConversationService aiService = AiConversationService(
    geminiService: geminiService,
    languageService: languageService,
  );
  final ISpeechToTextService sttService = MockSpeechToTextService();
  final ITextToSpeechService ttsService = MockTextToSpeechService();
  final LocalMemoryService memoryService = LocalMemoryService();
  final LocalConversationService conversationService = LocalConversationService();
  final LocalProfileService profileService = LocalProfileService();
  final SuggestionService suggestionService = SuggestionService();
  final ThemeProvider themeProvider = ThemeProvider();

  void dispose() {
    sttService.dispose();
    ttsService.dispose();
    memoryService.dispose();
    conversationService.dispose();
    profileService.dispose();
    themeProvider.dispose();
  }
}
