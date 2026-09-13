/// Supported languages for APDM's conversational and voice interactions.
enum AppLanguage {
  tamil('Tamil', 'Tamil Pure', 'TA'),
  english('English', 'English', 'EN'),
  tanglish('Tanglish', 'Tanglish Natural', 'TN');

  final String displayName;
  final String nativeLabel;
  final String code;

  const AppLanguage(this.displayName, this.nativeLabel, this.code);
}
