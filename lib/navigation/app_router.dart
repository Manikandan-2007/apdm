import 'package:flutter/material.dart';
import '../models/conversation_session.dart';
import '../screens/chat/main_chat_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/history/session_detail_screen.dart';
import '../screens/memory/memory_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/voice/voice_conversation_screen.dart';
import 'main_scaffold.dart';

/// Centralized route definitions and route generator for APDM.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String main = '/main';
  static const String chat = '/chat';
  static const String voice = '/voice';
  static const String memory = '/memory';
  static const String history = '/history';
  static const String sessionDetail = '/history/detail';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      case chat:
        return MaterialPageRoute(builder: (_) => const MainChatScreen());

      case voice:
        final topic = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => VoiceConversationScreen(initialTopic: topic),
        );

      case sessionDetail:
        final session = routeSettings.arguments as ConversationSession;
        return MaterialPageRoute(
          builder: (_) => SessionDetailScreen(session: session),
        );

      case memory:
        return MaterialPageRoute(builder: (_) => const MemoryScreen());

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
