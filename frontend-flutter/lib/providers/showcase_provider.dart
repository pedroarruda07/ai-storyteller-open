import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseProvider with ChangeNotifier {
  bool _hasShownStoryShowcase = false;

  bool get hasShownStoryShowcase => _hasShownStoryShowcase;

  ShowcaseProvider() {
    _loadShowcaseFlag();
  }

  Future<void> _loadShowcaseFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hasShownStoryShowcase = prefs.getBool('hasShownStoryShowcase') ?? false;
    notifyListeners();
  }

  Future<void> setShowcaseShown() async {
    _hasShownStoryShowcase = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownStoryShowcase', true);
    notifyListeners();
  }
}