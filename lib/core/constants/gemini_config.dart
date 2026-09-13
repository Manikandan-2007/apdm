/// Configuration and security management for Google Gemini API integration.
class GeminiConfig {
  GeminiConfig._();

  /// Default model endpoint (can be overridden via GEMINI_MODEL env)
  static const String _envModel = String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-1.5-flash');
  static String _runtimeModel = '';
  static String get defaultModel => _runtimeModel.isNotEmpty ? _runtimeModel : _envModel;
  static void setModel(String model) {
    _runtimeModel = model.trim();
  }

  static const String apiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Environment variable key: --dart-define=GEMINI_API_KEY=your_key_here
  /// or from .env via --dart-define-from-file=.env
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Runtime configurable key (can be set dynamically in app settings / runtime)
  static String _runtimeApiKey = '';

  /// Retrieve the active API key (runtime override takes precedence over compile-time define)
  static String get apiKey {
    if (_runtimeApiKey.isNotEmpty) return _runtimeApiKey;
    return _envApiKey;
  }

  /// Update the runtime API key
  static void setApiKey(String key) {
    _runtimeApiKey = key.trim();
  }

  /// Whether a valid live Gemini API key is configured
  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Default generation parameters
  static const double defaultTemperature = 0.7;
  static const int defaultMaxOutputTokens = 600;

  /// Missing information fallback in natural Tanglish
  static const String missingMemoryFallbackTanglish =
      'Adha pathi enakku memory-la information illa. Nee venumna adha APDM-la add pannalaam.';

  static const String missingMemoryFallbackEnglish =
      'I do not have information about that stored in APDM memory. You can add it anytime to the family memories archive.';
}
