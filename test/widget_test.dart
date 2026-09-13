import 'package:flutter_test/flutter_test.dart';
import 'package:apdm/main.dart';
import 'package:apdm/core/constants/app_strings.dart';
import 'package:apdm/models/language.dart';
import 'package:apdm/models/memory.dart';
import 'package:apdm/models/memorial_profile.dart';
import 'package:apdm/models/chat_message.dart';
import 'package:apdm/services/ai_service.dart';
import 'package:apdm/services/language_service.dart';
import 'package:apdm/services/service_locator.dart';
import 'package:apdm/services/suggestion_service.dart';
import 'package:apdm/core/theme/theme_provider.dart';

void main() {
  group('APDM Mobile App & Screen Smoke Tests', () {
    testWidgets('APDM App boots successfully and transitions from Splash to Main Chat Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ApdmApp());

      // Verify APDM branding on splash
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appSubtitle), findsOneWidget);
      expect(find.text('Tap anywhere to enter'), findsOneWidget);

      // Advance clock past splash screen auto-transition timer & fade animation
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 800));

      // Verify Mobile Bottom Navigation tabs
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Memories'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify Main Chat Screen components
      expect(find.text('Enna pesalaam?'), findsOneWidget);
      expect(find.text('Message APDM in Tanglish / English...'), findsOneWidget);
    });
  });

  group('Language Detection Service Unit Tests', () {
    final detector = LocalLanguageDetector();

    test('Detects pure Tamil Unicode script when entered', () {
      expect(detector.detectLanguage('வணக்கம் எப்படி இருக்கீங்க?'), AppLanguage.tamil);
      expect(detector.detectLanguage('அப்பாவின் நினைவுகள் பற்றி சொல்லுங்கள்'), AppLanguage.tamil);
      expect(detector.detectLanguage('காலை வணக்கம்'), AppLanguage.tamil);
    });

    test('Detects Tanglish (Tamil written in Latin script)', () {
      expect(detector.detectLanguage('Appa pathi solunga, enaku romba miss aguthu'), AppLanguage.tanglish);
      expect(detector.detectLanguage('Enna aachu avangalukku? Romba kashtama irukku'), AppLanguage.tanglish);
      expect(detector.detectLanguage('Nalla irukingala?'), AppLanguage.tanglish);
      expect(detector.detectLanguage('Kaapi kudipingala?'), AppLanguage.tanglish);
    });

    test('Detects English for standard English utterances', () {
      expect(detector.detectLanguage('Tell me about his favorite coffee and morning routine'), AppLanguage.english);
      expect(detector.detectLanguage('What was his advice on patience?'), AppLanguage.english);
      expect(detector.detectLanguage('Can you remember our childhood memories?'), AppLanguage.english);
    });
  });

  group('Real AI Conversational Engine & Context Continuity Tests', () {
    late IAiConversationService aiService;
    late List<Memory> memories;
    late MemorialProfile profile;
    final tamilScriptRegex = RegExp(r'[\u0B80-\u0BFF]');

    setUp(() {
      aiService = ServiceLocator.instance.aiService;
      memories = ServiceLocator.instance.memoryService.memories;
      profile = ServiceLocator.instance.profileService.profile;
    });

    test('Test 1: "Appa, Meenu pathi pesunga." produces contextual Meenu memory response', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, Meenu pathi pesunga.',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.tanglish);
      expect(result.text.contains('Meenu'), isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 2: "Appa, Dinesh business eppadi poguthu?" produces contextual Dinesh response', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, Dinesh business eppadi poguthu?',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.tanglish);
      expect(result.text.contains('Dinesh'), isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 3: "Appa, Padma kitta enna pesuveenga?" produces contextual Padma response', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, Padma kitta enna pesuveenga?',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.tanglish);
      expect(result.text.contains('Padma'), isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 4: "Appa, enakku konjam advice venum." produces contextual wisdom response', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, enakku konjam advice venum.',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.tanglish);
      expect(result.text.toLowerCase().contains('porumai') || result.text.toLowerCase().contains('unmai'), isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 5: "Can you tell me something about Meenu?" produces English contextual response', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Can you tell me something about Meenu?',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.english);
      expect(result.text.contains('Meenu'), isTrue);
      expect(result.text.contains('family'), isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 6: "Appa, innikku romba kashtama irukku." produces solace and comfort', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, innikku romba kashtama irukku.',
        memories: memories,
        profile: profile,
      );
      expect(result.language, AppLanguage.tanglish);
      expect(result.text.contains('Manasa'), isTrue);
      expect(result.text != 'Appa, innikku romba kashtama irukku.', isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Test 7: Multi-turn pronoun continuity resolves "avakku" to Meenu and does not echo', () async {
      final history = [
        ChatMessage(
          id: 'turn_1_u',
          text: 'Appa, Meenu college-la busy-a irukka.',
          sender: MessageSender.user,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          detectedLanguage: AppLanguage.tanglish,
        ),
        ChatMessage(
          id: 'turn_1_a',
          text: 'Meenu pathi nenaichaale santhosham. Ava romba dhairiyama padipa.',
          sender: MessageSender.ai,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          detectedLanguage: AppLanguage.tanglish,
        ),
      ];

      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Avakku exam irukku.',
        memories: memories,
        profile: profile,
        conversationHistory: history,
      );

      expect(result.language, AppLanguage.tanglish);
      // Must understand "avakku" = Meenu from history
      expect(result.text.contains('Meenu'), isTrue);
      // Must NOT just repeat the user's sentence
      expect(result.text != 'Avakku exam irukku.', isTrue);
      expect(tamilScriptRegex.hasMatch(result.text), isFalse);
    });

    test('Memory Safety: Unstored memory query returns graceful fallback without inventing facts', () async {
      final result = await aiService.generateMultilingualResponse(
        userUtterance: 'Appa, ungaloda car number and bank property enna?',
        memories: memories,
        profile: profile,
      );
      expect(result.text, 'Adha pathi enakku memory-la information illa. Nee venumna adha APDM-la add pannalaam.');
    });
  });

  group('Memory Service Unit Tests', () {
    test('Initial sample memories are seeded across categories', () {
      final memoryService = ServiceLocator.instance.memoryService;
      expect(memoryService.memories.isNotEmpty, isTrue);
      expect(memoryService.memories.length, greaterThanOrEqualTo(6));

      // Verify filtering
      final familyMemories = memoryService.filterByCategory(MemoryCategory.family);
      expect(familyMemories.any((m) => m.category == MemoryCategory.family), isTrue);

      final favoritesMemories = memoryService.filterByCategory(MemoryCategory.favorites);
      expect(favoritesMemories.any((m) => m.category == MemoryCategory.favorites), isTrue);
    });

    test('Add, search, and delete memory works correctly', () async {
      final memoryService = ServiceLocator.instance.memoryService;
      final initialCount = memoryService.memories.length;

      final testMemory = Memory(
        id: 'test_mem_001',
        title: 'Storytelling in the Evening',
        content: 'Sundaram told stories from Ponniyin Selvan every evening.',
        category: MemoryCategory.stories,
        createdAt: DateTime.now(),
        tags: const ['Stories', 'Evening'],
        emotionTag: 'Nostalgic',
      );

      await memoryService.addMemory(testMemory);
      expect(memoryService.memories.length, initialCount + 1);

      // Search
      final searchResults = memoryService.searchMemories('Ponniyin');
      expect(searchResults.any((m) => m.id == 'test_mem_001'), isTrue);

      // Delete
      await memoryService.deleteMemory('test_mem_001');
      expect(memoryService.memories.length, initialCount);
    });
  });

  group('Conversation Service Unit Tests', () {
    test('Start new session, add multilingual messages, and end session', () async {
      final convService = ServiceLocator.instance.conversationService;
      final initialSessionCount = convService.sessions.length;

      final session = await convService.startNewSession(customTitle: 'Tanglish Reflection');
      expect(convService.activeSession, isNotNull);
      expect(convService.activeSession?.title, 'Tanglish Reflection');

      final userMsg = ChatMessage(
        id: 'msg_u_1',
        text: 'Appavin ninaivugal patri pesuvom',
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        detectedLanguage: AppLanguage.tanglish,
      );
      await convService.addMessageToActiveSession(userMsg);
      expect(convService.activeSession?.messages.length, 1);

      await convService.endActiveSession();
      expect(convService.activeSession, isNull);
      expect(convService.sessions.length, initialSessionCount + 1);

      // Clean up test session
      await convService.deleteSession(session.id);
      expect(convService.sessions.length, initialSessionCount);
    });
  });

  group('Theme Provider & Options Unit Tests', () {
    test('Toggles theme between dark and light correctly', () {
      final themeProvider = ServiceLocator.instance.themeProvider;
      final initialMode = themeProvider.isDarkMode;

      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, !initialMode);

      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, initialMode);
    });

    test('Switches between all 6 memorial theme presets with dynamic palette generation', () {
      final themeProvider = ServiceLocator.instance.themeProvider;

      for (final preset in AppThemePreset.values) {
        themeProvider.setActivePreset(preset);
        expect(themeProvider.activePreset, preset);

        final palette = themeProvider.currentPalette;
        expect(palette.primary, isNotNull);
        expect(palette.englishName, preset.nameEnglish);
        expect(preset.nameTamil.isNotEmpty, isTrue);
        expect(preset.description.isNotEmpty, isTrue);
      }
    });

    test('Toggles and manages memorial options (Glow, Bubble Style, Tones, Honorifics, Biometrics)', () {
      final themeProvider = ServiceLocator.instance.themeProvider;

      // Ambient Glow
      themeProvider.setAmbientGlow(false);
      expect(themeProvider.ambientGlow, isFalse);
      themeProvider.toggleAmbientGlow();
      expect(themeProvider.ambientGlow, isTrue);

      // Bubble Style
      themeProvider.setBubbleStyle(BubbleStyle.gentleGlow);
      expect(themeProvider.bubbleStyle, BubbleStyle.gentleGlow);
      themeProvider.setBubbleStyle(BubbleStyle.frostedGlass);
      expect(themeProvider.bubbleStyle, BubbleStyle.frostedGlass);

      // Companion Tone
      themeProvider.setCompanionTone(CompanionTone.wiseGuiding);
      expect(themeProvider.companionTone, CompanionTone.wiseGuiding);

      // Language Mode
      themeProvider.setLanguageMode('tamil');
      expect(themeProvider.languageMode, 'tamil');

      // Speech Pace & Pitch
      themeProvider.setSpeechPace(0.8);
      expect(themeProvider.speechPace, 0.8);
      themeProvider.setSpeechPitch(1.1);
      expect(themeProvider.speechPitch, 1.1);

      // Honorifics & Reminders
      themeProvider.toggleHonorifics();
      themeProvider.toggleProactiveReminders();
      themeProvider.toggleAutoPlayVoice();
      themeProvider.toggleHapticFeedback();
      themeProvider.toggleBiometricLock();
    });
  });

  group('Suggested Conversations & Innum Paaru System Unit Tests', () {
    test('SuggestionService contains 12 categories and 80+ Tanglish starters with zero Tamil script', () {
      final categories = SuggestionService.categories;
      expect(categories.length, 12);

      // Verify category IDs
      final expectedCategoryIds = [
        'meenu',
        'dinesh',
        'padma',
        'family',
        'food',
        'childhood',
        'advice',
        'daily',
        'casual',
        'memories',
        'emotional',
        'stories',
      ];
      for (final id in expectedCategoryIds) {
        expect(categories.any((c) => c.id == id), isTrue, reason: 'Missing category $id');
        final prompts = SuggestionService.getPromptsByCategory(id);
        expect(prompts.isNotEmpty, isTrue, reason: 'Category $id should have prompts');
      }

      final allPrompts = SuggestionService.allPrompts;
      expect(allPrompts.length, greaterThanOrEqualTo(80));

      // Assert zero Tamil unicode in all prompt texts
      final tamilScriptRegex = RegExp(r'[\u0B80-\u0BFF]');
      for (final prompt in allPrompts) {
        expect(tamilScriptRegex.hasMatch(prompt.prompt), isFalse,
            reason: 'Found Tamil unicode in prompt: "${prompt.prompt}"');
        expect(prompt.shortLabel.isNotEmpty, isTrue);
      }

      // Test Featured rotation
      final featured = SuggestionService.getFeaturedSuggestions(seed: 42);
      expect(featured.isNotEmpty, isTrue);
      expect(featured.length, greaterThanOrEqualTo(6));
    });
  });
}

