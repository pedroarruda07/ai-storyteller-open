import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', locale.languageCode);
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('locale');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}