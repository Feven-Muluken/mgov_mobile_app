import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'language_model.dart';

/// Language Provider
///
/// Manages the current language state and provides language switching functionality
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  AppLanguage _currentLanguage = AppLanguage.English;
  LanguageStrings _strings = EnglishStrings();

  AppLanguage get currentLanguage => _currentLanguage;
  LanguageStrings get strings => _strings;

  /// Initialize the language provider and load saved language
  Future<void> initialize() async {
    await _loadSavedLanguage();
  }

  /// Load the saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);

      if (savedLanguageCode != null) {
        final savedLanguage = AppLanguage.values.firstWhere(
          (lang) => lang.code == savedLanguageCode,
          orElse: () => AppLanguage.English,
        );
        await changeLanguage(savedLanguage, savePreference: false);
      }
    } catch (e) {
      // If there's an error loading the language, default to English
      _currentLanguage = AppLanguage.English;
      _strings = EnglishStrings();
    }  
  }

  /// Change the current language
  Future<void> changeLanguage(
    AppLanguage language, {
    bool savePreference = true,
  }) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    _strings = _getLanguageStrings(language);

    if (savePreference) {
      await _saveLanguagePreference(language);
    }

    notifyListeners();
  }

  /// Save language preference to SharedPreferences
  Future<void> _saveLanguagePreference(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (e) {
      // Handle error silently - language will still work for current session
      debugPrint('Error saving language preference: $e');
    }
  }

  /// Get language strings for the specified language
  LanguageStrings _getLanguageStrings(AppLanguage language) {
    switch (language) {
      case AppLanguage.English:
        return EnglishStrings();
      case AppLanguage.Amharic:
        return AmharicStrings();
    }
  }

  /// Toggle between English and Amharic
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == AppLanguage.English
        ? AppLanguage.Amharic
        : AppLanguage.English;
    await changeLanguage(newLanguage);
  }

  /// Check if current language is RTL (Right-to-Left)
  bool get isRTL {
    // Amharic is written left-to-right, but if you add Arabic later, this would be useful
    return false;
  }

  /// Get text direction for the current language
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Get locale for the current language
  Locale get locale => Locale(_currentLanguage.code);
}

/// Extension to easily access language provider from BuildContext
extension LanguageContext on BuildContext {
  /// Access LanguageProvider without listening to changes
  LanguageProvider get languageProvider => read<LanguageProvider>();
  
  /// Access language strings with automatic rebuild on language change
  /// Use this in build() method
  LanguageStrings get strings => watch<LanguageProvider>().strings;
  
  /// Access language strings WITHOUT listening (for event handlers, getters, etc.)
  /// Use this in onPressed, getters, or any code outside build()
  LanguageStrings get stringsNoListen => read<LanguageProvider>().strings;
  
  /// Access current language with automatic rebuild
  AppLanguage get currentLanguage => watch<LanguageProvider>().currentLanguage;
  
  /// Access current language WITHOUT listening (for event handlers)
  AppLanguage get currentLanguageNoListen => read<LanguageProvider>().currentLanguage;
}

