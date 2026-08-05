import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    final countryCode = prefs.getString('countryCode') ?? 'US';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  String get languageName {
    switch (_locale.languageCode) {
      case 'te': return 'తెలుగు';
      case 'ta': return 'தமிழ்';
      case 'hi': return 'हिन्दी';
      default: return 'English (US)';
    }
  }

  String get shortName {
    switch (_locale.languageCode) {
      case 'te': return 'IN TE';
      case 'ta': return 'IN TA';
      case 'hi': return 'IN HI';
      default: return 'US EN';
    }
  }
}
