import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static const String _apiKeyKey = 'gemini_api_key';

  /// Saves the API key locally on the device
  Future<void> saveLocalApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey.trim());
      debugPrint('✓ Saved API key locally in SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving local API key: $e');
    }
  }

  /// Loads the API key stored locally on the device
  Future<String?> getLocalApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_apiKeyKey);
      if (key != null && key.isNotEmpty) {
        debugPrint('🔑 Retrieved local API key from SharedPreferences');
        return key;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading local API key: $e');
      return null;
    }
  }
}
