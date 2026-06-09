class ApiKeys {
  /// Default Gemini API Key configuration.
  /// You can pass this at compile time using:
  /// `--dart-define=GEMINI_API_KEY=your_key_here`
  /// Or paste your key directly in the defaultValue below.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', 
  );
}
