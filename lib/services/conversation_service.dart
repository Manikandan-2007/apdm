import 'package:flutter/foundation.dart';
import '../models/conversation_session.dart';
import '../models/chat_message.dart';
import '../models/language.dart';

/// Abstract contract for conversation session lifecycle and persistence.
abstract class IConversationService {
  List<ConversationSession> get sessions;
  ConversationSession? get activeSession;
  Future<ConversationSession> startNewSession({String? customTitle});
  Future<void> addMessageToActiveSession(ChatMessage message);
  Future<void> endActiveSession({String? summary});
  Future<void> loadSession(String id);
  Future<void> renameSession(String id, String newTitle);
  Future<void> deleteSession(String id);
  List<ConversationSession> searchSessions(String query);
}

/// In-memory reactive implementation supporting session continuity,
/// multilingual exchanges, and session switching.
class LocalConversationService extends ChangeNotifier implements IConversationService {
  final List<ConversationSession> _sessions = [];
  ConversationSession? _activeSession;

  LocalConversationService() {
    _seedInitialSessions();
    // Start initial clean session for immediate chatting
    startNewSession(customTitle: 'Current Conversation');
  }

  @override
  List<ConversationSession> get sessions => List.unmodifiable(_sessions);

  @override
  ConversationSession? get activeSession => _activeSession;

  @override
  Future<ConversationSession> startNewSession({String? customTitle}) async {
    // If active session has messages, archive it first
    if (_activeSession != null && _activeSession!.messages.isNotEmpty) {
      final exists = _sessions.any((s) => s.id == _activeSession!.id);
      if (!exists) {
        _sessions.insert(0, _activeSession!);
      } else {
        final idx = _sessions.indexWhere((s) => s.id == _activeSession!.id);
        _sessions[idx] = _activeSession!;
      }
    }

    final newSession = ConversationSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: customTitle ?? 'New Conversation',
      startedAt: DateTime.now(),
      summaryPreview: 'A thoughtful reflection on cherished family moments.',
      messages: [],
      topics: const ['Remembrance'],
    );
    _activeSession = newSession;
    notifyListeners();
    return newSession;
  }

  @override
  Future<void> addMessageToActiveSession(ChatMessage message) async {
    if (_activeSession == null) {
      await startNewSession();
    }
    final updatedMessages = List<ChatMessage>.from(_activeSession!.messages)..add(message);

    // Auto-update title based on first user message if title is default
    var sessionTitle = _activeSession!.title;
    if (_activeSession!.messages.isEmpty && message.isFromUser) {
      sessionTitle = message.text.length > 32
          ? '${message.text.substring(0, 32)}...'
          : message.text;
    }

    _activeSession = _activeSession!.copyWith(
      title: sessionTitle,
      messages: updatedMessages,
      summaryPreview: message.text,
      durationSeconds: DateTime.now().difference(_activeSession!.startedAt).inSeconds,
    );

    // Keep sessions list updated in real-time
    final existingIdx = _sessions.indexWhere((s) => s.id == _activeSession!.id);
    if (existingIdx != -1) {
      _sessions[existingIdx] = _activeSession!;
    } else {
      _sessions.insert(0, _activeSession!);
    }

    notifyListeners();
  }

  @override
  Future<void> endActiveSession({String? summary}) async {
    if (_activeSession != null && _activeSession!.messages.isNotEmpty) {
      final sessionToSave = _activeSession!.copyWith(
        summaryPreview: summary ??
            (_activeSession!.messages.isNotEmpty
                ? _activeSession!.messages.last.text
                : 'Brief moment of reflection.'),
        durationSeconds: DateTime.now().difference(_activeSession!.startedAt).inSeconds.clamp(10, 3600),
      );
      final idx = _sessions.indexWhere((s) => s.id == sessionToSave.id);
      if (idx != -1) {
        _sessions[idx] = sessionToSave;
      } else {
        _sessions.insert(0, sessionToSave);
      }
      _activeSession = null;
      notifyListeners();
    }
  }

  @override
  Future<void> loadSession(String id) async {
    final session = _sessions.firstWhere((s) => s.id == id, orElse: () => _sessions.first);
    _activeSession = session;
    notifyListeners();
  }

  @override
  Future<void> renameSession(String id, String newTitle) async {
    final idx = _sessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final updated = _sessions[idx].copyWith(title: newTitle);
      _sessions[idx] = updated;
      if (_activeSession?.id == id) {
        _activeSession = updated;
      }
      notifyListeners();
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) {
      _activeSession = null;
      await startNewSession();
    }
    notifyListeners();
  }

  @override
  List<ConversationSession> searchSessions(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(_sessions);
    final q = query.toLowerCase().trim();
    return _sessions.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.summaryPreview.toLowerCase().contains(q) ||
          s.messages.any((m) => m.text.toLowerCase().contains(q));
    }).toList();
  }

  void _seedInitialSessions() {
    final now = DateTime.now();
    _sessions.addAll([
      ConversationSession(
        id: 'sess_tamil_1',
        title: 'Appavin Ninaivugal (Appa\'s Guidance)',
        startedAt: now.subtract(const Duration(hours: 2)),
        durationSeconds: 190,
        summaryPreview: 'Appa sonna porumai matrum vaazhkkai advices patri pesiyadhu.',
        topics: const ['Family Advice', 'Patience', 'Tanglish'],
        messages: [
          ChatMessage(
            id: 'm_ta_1',
            text: 'Appa, innikku enakku romba kashtama irukku.',
            sender: MessageSender.user,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 3)),
            detectedLanguage: AppLanguage.tanglish,
          ),
          ChatMessage(
            id: 'm_ta_2',
            text: 'Naan ungal unarvugalai muzhumaiyaaga purinthu kolgiren... Appa eppodhum solvathu pola, endha oru kadinamana soozhnilayilum porumai ungalai vazhinadathum. Manam vittu sollunga, enna aachu?',
            sender: MessageSender.ai,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 2)),
            detectedLanguage: AppLanguage.tanglish,
          ),
        ],
      ),
      ConversationSession(
        id: 'sess_tanglish_1',
        title: 'Childhood & Evening Walks',
        startedAt: now.subtract(const Duration(days: 1, hours: 4)),
        durationSeconds: 240,
        summaryPreview: 'Talking about evening walks to the tea stall and school memories.',
        topics: const ['Childhood', 'Tanglish'],
        messages: [
          ChatMessage(
            id: 'm_tn_1',
            text: 'Appa, tell me about our evening walks after school.',
            sender: MessageSender.user,
            timestamp: now.subtract(const Duration(days: 1, hours: 4, minutes: 4)),
            detectedLanguage: AppLanguage.tanglish,
          ),
          ChatMessage(
            id: 'm_tn_2',
            text: 'Those evening walks were so special to Appa. School mudinju ungaloda nadanthu porathum, tea stall-la biscuit vaangi kuduthu unga stories kekkurathum avarukku romba pudikkum.',
            sender: MessageSender.ai,
            timestamp: now.subtract(const Duration(days: 1, hours: 4, minutes: 3)),
            detectedLanguage: AppLanguage.tanglish,
          ),
          ChatMessage(
            id: 'm_tn_3',
            text: 'I really miss those days. Thank you for reminding me.',
            sender: MessageSender.user,
            timestamp: now.subtract(const Duration(days: 1, hours: 4, minutes: 2)),
            detectedLanguage: AppLanguage.english,
          ),
          ChatMessage(
            id: 'm_tn_4',
            text: 'Holding onto these precious memories keeps Appa\'s warmth and love forever alive in your heart.',
            sender: MessageSender.ai,
            timestamp: now.subtract(const Duration(days: 1, hours: 4, minutes: 1)),
            detectedLanguage: AppLanguage.english,
          ),
        ],
      ),
    ]);
  }
}
