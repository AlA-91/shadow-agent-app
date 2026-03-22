class ShadowAgent {
  final String apiKey;

  ShadowAgent({required this.apiKey});

  String get model => 'gemini-2.0-flash';

  bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY';
}
