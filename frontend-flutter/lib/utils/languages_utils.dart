import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';

Map<String, String> languageNames = {
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'fr': 'Français',
  'de': 'Deutsch',
  'da': 'Dansk',
  'ja': '日本語',
  //add more
};

List<String> getLanguagesName(List<Locale> locales) {
  return locales.map((locale) {
    String languageCode = locale.languageCode;
    return languageNames[languageCode] ?? languageCode;
  }).toList();
}

String getCurrentLanguage(BuildContext context) {
  var localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  Locale locale = localeProvider.locale;

  return languageNames[locale.languageCode] ?? 'English';
}

String getFlagCode(String languageCode) {
  switch (languageCode) {
    case ('en'):
      return 'gb';
    case ('da'):
      return 'dk';
    case ('ja'):
      return 'jp';
    default:
      return languageCode;
  }
}

double calculateFontSize(String title) {
  if (title.length <= 20) return 22;
  if (title.length <= 25) return 18;
  if (title.length <= 30) return 16;
  return 14;
}
