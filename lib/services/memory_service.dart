import 'package:flutter/foundation.dart';
import '../models/memory.dart';

/// Abstract contract for memory persistence and operations.
abstract class IMemoryService {
  List<Memory> get memories;
  Future<void> addMemory(Memory memory);
  Future<void> updateMemory(Memory memory);
  Future<void> deleteMemory(String id);
  List<Memory> filterByCategory(MemoryCategory? category);
  List<Memory> searchMemories(String query);
}

/// In-memory reactive implementation seeded with realistic memorial records.
class LocalMemoryService extends ChangeNotifier implements IMemoryService {
  final List<Memory> _memories = [];

  LocalMemoryService() {
    _seedInitialMemories();
  }

  @override
  List<Memory> get memories => List.unmodifiable(_memories);

  @override
  Future<void> addMemory(Memory memory) async {
    _memories.insert(0, memory);
    notifyListeners();
  }

  @override
  Future<void> updateMemory(Memory memory) async {
    final index = _memories.indexWhere((m) => m.id == memory.id);
    if (index != -1) {
      _memories[index] = memory;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteMemory(String id) async {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  @override
  List<Memory> filterByCategory(MemoryCategory? category) {
    if (category == null) return List.unmodifiable(_memories);
    return _memories.where((m) => m.category == category).toList();
  }

  @override
  List<Memory> searchMemories(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(_memories);
    final q = query.toLowerCase().trim();
    return _memories.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.content.toLowerCase().contains(q) ||
          m.tags.any((t) => t.toLowerCase().contains(q)) ||
          m.category.label.toLowerCase().contains(q);
    }).toList();
  }

  void _seedInitialMemories() {
    _memories.addAll([
      Memory(
        id: 'mem_meenu_1',
        title: 'Meenu-vin Siripu & College Kanavugal 👧✨',
        content:
            'Meenu eppavum Appa-voda chella ponnu ❤️. College first day annikku bayandha pothu, Appa thol-la kai pottu "Unnala mudiyum da chellam, dhairiyama poyi padichu jeichu kaatu 🌟" nu sonnaar. Andha anbu eppavum un kooda thaan irukku da chellam.',
        category: MemoryCategory.personal,
        memoryDate: DateTime(2021, 8, 16),
        createdAt: DateTime(2023, 1, 10),
        tags: const ['Meenu', 'ChellaPonnu', 'College', 'Anbu'],
        emotionTag: 'Sentimental ❤️',
      ),
      Memory(
        id: 'mem_dinesh_1',
        title: 'Dinesh-kku Appa Kodutha Thairiyam 💼🌟',
        content:
            'Dinesh business start panna nenaichappo romba bayandhaan. Appa avan kaiya pidichu "Nee nalla uzhaikira paiyan da, tholvi vandha bayapadaatha, nambikkaiyoda munneru 📈💪. Naan un pinnaadi eppavum iruppen" nu dhairiyam sonnaar. Andha vaarthai thaan innikkum vazhi kaattudhu, ah right?',
        category: MemoryCategory.personal,
        memoryDate: DateTime(2019, 11, 20),
        createdAt: DateTime(2023, 2, 1),
        tags: const ['Dinesh', 'Business', 'Uzhaipu', 'Nambikkai'],
        emotionTag: 'Inspiring 🌟',
      ),
      Memory(
        id: 'mem_padma_1',
        title: 'Padma & Bawa-vin 30 Varusha Anbu 🌸🍲',
        content:
            'Padma samaikura vendakkai poriyal-na Bawa-vukku uyire 🍲❤️. Kaalaila coffee pottu kuduthutu veranda-la renduperum ukaandhu pazhaya kathaigal pesuvaanga ☕🌸. "Padma, un kooda irundha ovvoru naalum oru varam" nu Bawa eppavum solluvaar. Andha manasu eppavum maaradhu.',
        category: MemoryCategory.family,
        memoryDate: DateTime(2020, 5, 12),
        createdAt: DateTime(2023, 2, 14),
        tags: const ['Padma', 'Bawa', 'Samayal', 'Anbu'],
        emotionTag: 'Cherished 🌸',
      ),
      Memory(
        id: 'mem_family_1',
        title: 'Sunday Family Saapaadu & Siripu 🏡❤️',
        content:
            'Sunday aana podhum, ellarum onna ukaandhu saapadanum-nu Appa solluvaar 🍲👨‍👩‍👧‍👦. Sambar vaasam veedu full-ah thookum, ellarum sirichu pesikittu irundha andha nimisham thaan namma veetoda periya pokkisham ✨. Andha santhosham eppavum namma veetla niraiva irukkum.',
        category: MemoryCategory.family,
        memoryDate: DateTime(2018, 7, 24),
        createdAt: DateTime(2023, 3, 5),
        tags: const ['Family', 'SundaySambar', 'Veedu', 'Pokkisham'],
        emotionTag: 'Heartwarming 🏡',
      ),
      Memory(
        id: 'mem_routine_1',
        title: 'Kaalai Kaapi & MS Amma Paattu ☕🎶',
        content:
            'Kaalaila 6:00 AM-kku brass filter-la decoction pottu, veranda-la ukaandhu newspaper padikira pazhakkam ☕📰. MS Amma suprabhatam background-la kettu namma veedey amaidhiya irukkum 🕊️✨. Andha amaidhi innum namma manasula irukku.',
        category: MemoryCategory.favorites,
        memoryDate: DateTime(2019, 3, 15),
        createdAt: DateTime(2023, 3, 20),
        tags: const ['FilterCoffee', 'KaalaiNeram', 'Amaidhi'],
        emotionTag: 'Peaceful 🕊️',
      ),
      Memory(
        id: 'mem_blessing_1',
        title: 'Appavin Manapoorva Aasirvaadham 💛🙏',
        content:
            '"Meenu, Dinesh, Padma... neenga ellarum oruvarukkoruvar anbaaga, orumaiyaaga irukkaanum ❤️. En aasirvaadham unga ovvoru moochilum eppavum thunaiyaaga irukkum 🌟🙏." Namma eppavum oru kudumbama thaan irukkom ❤️.',
        category: MemoryCategory.messages,
        memoryDate: DateTime(2022, 1, 10),
        createdAt: DateTime(2023, 4, 1),
        tags: const ['Aasirvaadham', 'Kudumbam', 'Blessings', 'Eternity'],
        emotionTag: 'Emotional 💛',
      ),
    ]);
  }
}
