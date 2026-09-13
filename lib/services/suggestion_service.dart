import 'dart:math';

/// Categorized suggestion model for APDM remembrance conversations.
class SuggestionCategory {
  final String id;
  final String title;
  final String icon;
  final String shortChip;

  const SuggestionCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.shortChip,
  });
}

class SuggestionPrompt {
  final String categoryId;
  final String prompt;
  final String shortLabel;

  const SuggestionPrompt({
    required this.categoryId,
    required this.prompt,
    required this.shortLabel,
  });
}

/// Service that provides 80+ natural Tanglish conversation starters
/// across 12 distinct categories.
class SuggestionService {
  static const List<SuggestionCategory> categories = [
    SuggestionCategory(id: 'meenu', title: 'Meenu', icon: '👧', shortChip: 'Meenu pathi'),
    SuggestionCategory(id: 'dinesh', title: 'Dinesh', icon: '💼', shortChip: 'Dinesh business'),
    SuggestionCategory(id: 'padma', title: 'Padma', icon: '🌸', shortChip: 'Padma kitta'),
    SuggestionCategory(id: 'family', title: 'Namma Family', icon: '🏡', shortChip: 'Namma family'),
    SuggestionCategory(id: 'food', title: 'Samayal / Food', icon: '🍲', shortChip: 'Vendakkai poriyal'),
    SuggestionCategory(id: 'childhood', title: 'Childhood', icon: '🎈', shortChip: 'Childhood memories'),
    SuggestionCategory(id: 'advice', title: 'Appa Advice', icon: '🌟', shortChip: 'Appa advice'),
    SuggestionCategory(id: 'daily', title: 'Daily Life', icon: '☕', shortChip: 'Innikku pesalama'),
    SuggestionCategory(id: 'casual', title: 'Casual Talk', icon: '💬', shortChip: 'Casual talk'),
    SuggestionCategory(id: 'memories', title: 'Memories', icon: '📸', shortChip: 'Old memories'),
    SuggestionCategory(id: 'emotional', title: 'Emotional Talk', icon: '💛', shortChip: 'Aaruthal'),
    SuggestionCategory(id: 'stories', title: 'Stories', icon: '📖', shortChip: 'Family story'),
  ];

  static const List<SuggestionPrompt> allPrompts = [
    // 1. MEENU
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan eppadi irukken nu kekkareengala?',
      shortLabel: 'Naan eppadi irukken?',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan ippo 3rd year college padikkuren.',
      shortLabel: '3rd year college',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, en college life eppadi poguthu nu pesalama?',
      shortLabel: 'En college life',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku college pathi enna advice solluveenga?',
      shortLabel: 'Enakku college advice',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan chinna vayasula eppadi iruppen?',
      shortLabel: 'Chinna vayasula naan',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan ungalukku yen ivlo chellam?',
      shortLabel: 'Naan yen ivlo chellam?',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, en kitta ippo pesina mudhala enna keppeenga?',
      shortLabel: 'En kitta mudhala enna keppeenga?',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, en future pathi enna solluveenga?',
      shortLabel: 'En future pathi advice',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan stress-a irundha eppadi encourage pannuveenga?',
      shortLabel: 'Stress-a irundha encourage',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku oru message sollunga.',
      shortLabel: 'Enakku oru message',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan college-la busy-a irundha enna solluveenga?',
      shortLabel: 'College busy aana advice',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, naan success aaganum-na enna advice kuduppeenga?',
      shortLabel: 'Success aaganum advice',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, en childhood-la ungalukku pidicha memory enna?',
      shortLabel: 'En childhood memory',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, en kooda irundha oru happy memory sollunga.',
      shortLabel: 'En kooda happy memory',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku neenga senja vendakkai poriyal nyabagam irukka?',
      shortLabel: 'Vendakkai poriyal nyabagam',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku vendakkai poriyal senja time-la enna nadandhuchu?',
      shortLabel: 'Vendakkai poriyal story',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku pidicha food pathi pesalama?',
      shortLabel: 'Enakku pidicha food',
    ),
    SuggestionPrompt(
      categoryId: 'meenu',
      prompt: 'Appa, enakku neenga solla virumbura oru vaarthai enna?',
      shortLabel: 'Enakku oru vaarthai',
    ),

    // 2. DINESH
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, en business eppadi poguthu nu kekkareengala?',
      shortLabel: 'En business eppadi poguthu?',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, naan ippo business paathuttu irukken.',
      shortLabel: 'Naan ippo business paakkuren',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, enakku business pathi enna advice solluveenga?',
      shortLabel: 'Enakku business advice',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, naan business-la busy-a irundha enna solluveenga?',
      shortLabel: 'Business busy-a irundha',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, naan edhaavadhu difficult decision edutha eppadi guide pannuveenga?',
      shortLabel: 'Difficult decision guide',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, enakku confidence venumna enna solluveenga?',
      shortLabel: 'Enakku confidence advice',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, enakku neenga kudutha best advice enna?',
      shortLabel: 'Enakku best advice',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, en future pathi enna hope vechurundheenga?',
      shortLabel: 'En future hope',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, naan tired-a irundha eppadi encourage pannuveenga?',
      shortLabel: 'Tired-a irundha encourage',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, en kitta ippo pesina mudhala enna keppeenga?',
      shortLabel: 'En kitta mudhala enna keppeenga?',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, en family responsibilities pathi enna solluveenga?',
      shortLabel: 'Family responsibilities',
    ),
    SuggestionPrompt(
      categoryId: 'dinesh',
      prompt: 'Appa, en business-la nalla poganum-na enna solluveenga?',
      shortLabel: 'Business nalla poganum advice',
    ),

    // 3. PADMA
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, naan eppadi irukken nu kekkareengala?',
      shortLabel: 'Naan eppadi irukken?',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, en kitta ippo pesina enna keppeenga?',
      shortLabel: 'En kitta enna keppeenga?',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, enakku oru message sollunga.',
      shortLabel: 'Enakku oru message',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, naan upset-a irundha eppadi pesuveenga?',
      shortLabel: 'Upset aana eppadi pesuveenga?',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, enakku neenga kudutha best advice enna?',
      shortLabel: 'Enakku best advice',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, namma rendu peroda favourite memory enna?',
      shortLabel: 'Rendu peroda favourite memory',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, en kooda irundha happy memory sollunga.',
      shortLabel: 'En kooda happy memory',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, family pathi en kitta enna pesuveenga?',
      shortLabel: 'Family pathi en kitta',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, enakku konjam aaruthala pesunga.',
      shortLabel: 'Enakku aaruthal',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, en kitta ippo enna sollanum-nu ninaikkireenga?',
      shortLabel: 'En kitta enna sollanum?',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, namma family life pathi pesalama?',
      shortLabel: 'Family life pathi pesalama?',
    ),
    SuggestionPrompt(
      categoryId: 'padma',
      prompt: 'Bawa, enakku thanks sollanum-na enna solluveenga?',
      shortLabel: 'Enakku thanks solluveengala?',
    ),

    // 4. NAMMA FAMILY
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family pathi pesalama?',
      shortLabel: 'Namma family pathi pesalama?',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family-la ungalukku romba pidicha memory enna?',
      shortLabel: 'Family-la romba pidicha memory',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma ellarum serndhu irundha happy moment enna?',
      shortLabel: 'Ellarum serndhu irundha moment',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family pathi ungalukku enna perumai?',
      shortLabel: 'Family pathi unga perumai',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, family-ku neenga eppavume sollra advice enna?',
      shortLabel: 'Family-ku eppavume sollra advice',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma childhood memories-la ungalukku pidichadhu edhu?',
      shortLabel: 'Childhood memories-la pidichadhu',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family-ku oru message sollunga.',
      shortLabel: 'Family-ku oru message',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, ellarum happy-a irukkanum-na enna solluveenga?',
      shortLabel: 'Ellarum happy-a irukka advice',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family-la ungalukku romba close-a irundha moment enna?',
      shortLabel: 'Romba close-a irundha moment',
    ),
    SuggestionPrompt(
      categoryId: 'family',
      prompt: 'Appa, namma family memories-la oru story sollunga.',
      shortLabel: 'Family memories story',
    ),

    // 5. FOOD / SAMAYAL
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, enakku vendakkai poriyal senja memory pathi pesunga.',
      shortLabel: 'Vendakkai poriyal memory',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, vendakkai poriyal yen ivlo virumbi senjeenga?',
      shortLabel: 'Vendakkai poriyal story',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, family-ku samayal pannina memories irukka?',
      shortLabel: 'Samayal pannina memories',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, namma family food memories-la ungalukku pidichadhu edhu?',
      shortLabel: 'Family food memories',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, enakku pidicha food pathi pesalama?',
      shortLabel: 'Enakku pidicha food',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, family-la yaarukku enna food pidikkum nu pesalama?',
      shortLabel: 'Yaarukku enna food pidikkum?',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, namma ellarum serndhu saapta memories sollunga.',
      shortLabel: 'Serndhu saapta memories',
    ),
    SuggestionPrompt(
      categoryId: 'food',
      prompt: 'Appa, neenga senja samayal-la ungalukku pidichadhu edhu?',
      shortLabel: 'Neenga senja samayal',
    ),

    // 6. CHILDHOOD
    SuggestionPrompt(
      categoryId: 'childhood',
      prompt: 'Appa, naan chinna vayasula eppadi iruppen?',
      shortLabel: 'Chinna vayasula naan',
    ),
    SuggestionPrompt(
      categoryId: 'childhood',
      prompt: 'Appa, namma chinna vayasula eppadi irundhom?',
      shortLabel: 'Chinna vayasula namma',
    ),
    SuggestionPrompt(
      categoryId: 'childhood',
      prompt: 'Appa, namma childhood-la oru happy story sollunga.',
      shortLabel: 'Childhood happy story',
    ),
    SuggestionPrompt(
      categoryId: 'childhood',
      prompt: 'Appa, unga childhood pathi oru story sollunga.',
      shortLabel: 'Unga childhood story',
    ),

    // 7. APPA ADVICE
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, life-la kashtam vandha enna pannanu solluveenga?',
      shortLabel: 'Life kashtam vandha enna pannanum?',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, padippu pathi enna advice kuduppeenga?',
      shortLabel: 'Padippu advice',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, family responsibilities pathi enna solluveenga?',
      shortLabel: 'Family responsibilities',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, confidence koranja enna solluveenga?',
      shortLabel: 'Confidence koranja advice',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, difficult decision edukkumbodhu enna yosikkanum?',
      shortLabel: 'Difficult decision edukkumbodhu',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, success pathi ungaloda advice enna?',
      shortLabel: 'Success pathi advice',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, family relationships important-a irukkanum-na enna solluveenga?',
      shortLabel: 'Family relationships important',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, future pathi oru advice sollunga.',
      shortLabel: 'Future advice',
    ),
    SuggestionPrompt(
      categoryId: 'advice',
      prompt: 'Appa, naan strong-a irukkanum-na enna solluveenga?',
      shortLabel: 'Naan strong-a irukka advice',
    ),

    // 8. DAILY LIFE
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, innikku konjam pesalama?',
      shortLabel: 'Innikku konjam pesalama?',
    ),
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, innikku enna pesalaam?',
      shortLabel: 'Innikku enna pesalaam?',
    ),
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, konjam neram unga kooda pesanum.',
      shortLabel: 'Konjam neram unga kooda pesanum',
    ),
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, innikku ungaloda pesanum pola irukku.',
      shortLabel: 'Ungaloda pesanum pola irukku',
    ),
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, innikku enakku epdi irukku nu kekkareengala?',
      shortLabel: 'Enakku epdi irukku nu kekkareengala?',
    ),
    SuggestionPrompt(
      categoryId: 'daily',
      prompt: 'Appa, enna pannitu irundheenga nu kekkanum pola irukku.',
      shortLabel: 'Enna pannitu irundheenga?',
    ),

    // 9. CASUAL TALK
    SuggestionPrompt(
      categoryId: 'casual',
      prompt: 'Appa, oru story sollunga.',
      shortLabel: 'Oru story sollunga',
    ),
    SuggestionPrompt(
      categoryId: 'casual',
      prompt: 'Appa, unga advice konjam venum.',
      shortLabel: 'Unga advice konjam venum',
    ),
    SuggestionPrompt(
      categoryId: 'casual',
      prompt: 'Appa, konjam sirikka vaikkura oru story sollunga.',
      shortLabel: 'Sirikka vaikkura story',
    ),
    SuggestionPrompt(
      categoryId: 'casual',
      prompt: 'Appa, namma old memories pathi pesalama?',
      shortLabel: 'Old memories pathi pesalama?',
    ),
    SuggestionPrompt(
      categoryId: 'casual',
      prompt: 'Appa, konjam pesunga.',
      shortLabel: 'Konjam pesunga',
    ),

    // 10. MEMORIES
    SuggestionPrompt(
      categoryId: 'memories',
      prompt: 'Appa, ungalukku romba nyabagam varra family moment enna?',
      shortLabel: 'Romba nyabagam varra moment',
    ),
    SuggestionPrompt(
      categoryId: 'memories',
      prompt: 'Appa, namma family-la marakka mudiyadha moment enna?',
      shortLabel: 'Marakka mudiyadha moment',
    ),
    SuggestionPrompt(
      categoryId: 'memories',
      prompt: 'Appa, namma ellarum serndhu irundha happy moment enna?',
      shortLabel: 'Serndhu irundha happy moment',
    ),
    SuggestionPrompt(
      categoryId: 'memories',
      prompt: 'Appa, namma family-la ungalukku romba pidicha memory enna?',
      shortLabel: 'Romba pidicha memory',
    ),

    // 11. EMOTIONAL TALK
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, innikku konjam low-a feel panren.',
      shortLabel: 'Innikku low-a feel panren',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, enakku konjam courage venum.',
      shortLabel: 'Enakku courage venum',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, miss panren.',
      shortLabel: 'Appa, miss panren',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, enakku oru nalla advice sollunga.',
      shortLabel: 'Nalla advice sollunga',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, konjam aaruthala pesunga.',
      shortLabel: 'Konjam aaruthala pesunga',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, naan strong-a irukkanum nu sollunga.',
      shortLabel: 'Naan strong-a irukkanum nu sollunga',
    ),
    SuggestionPrompt(
      categoryId: 'emotional',
      prompt: 'Appa, innikku konjam unga voice kekkanum pola irukku.',
      shortLabel: 'Unga voice kekkanum pola irukku',
    ),

    // 12. STORIES
    SuggestionPrompt(
      categoryId: 'stories',
      prompt: 'Appa, namma family-la nadandha oru funny memory sollunga.',
      shortLabel: 'Funny memory story',
    ),
    SuggestionPrompt(
      categoryId: 'stories',
      prompt: 'Appa, oru pazhaya family story sollunga.',
      shortLabel: 'Pazhaya family story',
    ),
    SuggestionPrompt(
      categoryId: 'stories',
      prompt: 'Appa, namma family memories-la oru story sollunga.',
      shortLabel: 'Family memories story',
    ),
    SuggestionPrompt(
      categoryId: 'stories',
      prompt: 'Appa, unga childhood pathi oru story sollunga.',
      shortLabel: 'Unga childhood story',
    ),
  ];

  /// Returns a curated rotating set of featured suggestions across varied categories.
  static List<SuggestionPrompt> getFeaturedSuggestions({int seed = 0}) {
    final rand = Random(seed == 0 ? DateTime.now().minute : seed);
    final selected = <SuggestionPrompt>[];

    // Pick top starters from distinct categories
    final keyCategories = ['meenu', 'dinesh', 'padma', 'food', 'family', 'advice', 'daily', 'emotional'];
    for (final catId in keyCategories) {
      final inCat = allPrompts.where((p) => p.categoryId == catId).toList();
      if (inCat.isNotEmpty) {
        selected.add(inCat[rand.nextInt(inCat.length)]);
      }
    }
    return selected;
  }

  /// Get all prompts for a specific category ID.
  static List<SuggestionPrompt> getPromptsByCategory(String categoryId) {
    return allPrompts.where((p) => p.categoryId == categoryId).toList();
  }
}
