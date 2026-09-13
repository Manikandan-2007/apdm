import '../models/language.dart';

/// Abstract contract for automatic multilingual language detection.
abstract class ILanguageDetectionService {
  AppLanguage detectLanguage(String text);
}

/// Production-ready local language detection identifying Tamil script,
/// Tanglish phonetic vocabulary, and English.
class LocalLanguageDetector implements ILanguageDetectionService {
  // Regex to detect Tamil Unicode block (\u0B80 to \u0BFF)
  static final RegExp _tamilScriptRegex = RegExp(r'[\u0B80-\u0BFF]');

  // Common Tanglish keywords frequently used in spoken conversations
  static final Set<String> _tanglishKeywords = {
    'appa', 'amma', 'thatha', 'paati', 'anna', 'akka', 'thambi', 'thangachi',
    'romba', 'kashtam', 'kashtama', 'kashtamaa', 'sollu', 'solunga', 'solren',
    'enakku', 'unaku', 'ungalukku', 'ennoda', 'unga', 'ungala', 'epdi', 'eppadi',
    'irukku', 'iruken', 'irukanga', 'irukingala', 'nalla', 'nallaa', 'enna', 'ethu', 'engayavathu',
    'theriyuma', 'puriyala', 'puriyuthu', 'vaanga', 'ponga', 'saapda', 'saaptacha',
    'pesa', 'pesalama', 'pesunga', 'aachu', 'kuzhappam', 'nenaipu', 'ninaivugal', 'theriyum',
    'innikku', 'innaiku', 'naalaikku', 'kooda', 'mattum', 'aana', 'illai', 'illa',
    'marakka', 'mudiyala', 'azhuga', 'santhosham', 'manasu', 'manasula',
    'kaapi', 'kudika', 'kudipingala', 'kudipanga', 'kudicha', 'pathi', 'pathina',
    'kadhai', 'kadhaigal', 'seri', 'aprom', 'appuram', 'kavala', 'kavalapadathinga', 'valikuthu',
  };

  @override
  AppLanguage detectLanguage(String text) {
    if (text.trim().isEmpty) return AppLanguage.english;

    // 1. Check for native Tamil script
    if (_tamilScriptRegex.hasMatch(text)) {
      return AppLanguage.tamil;
    }

    // 2. Tokenize lowercase words and check for Tanglish keywords
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));

    var tanglishCount = 0;
    for (final word in words) {
      if (_tanglishKeywords.contains(word)) {
        tanglishCount++;
      }
    }

    // If at least one distinct keyword or high ratio of tanglish words is found
    if (tanglishCount > 0) {
      return AppLanguage.tanglish;
    }

    // 3. Default to English
    return AppLanguage.english;
  }
}
