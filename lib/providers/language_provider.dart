import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Languages {
  ru('Русский язык', Locale('ru', 'RU'), 'ru'),
  kz('Қазақ тілі', Locale('kk', 'KK'), 'kz'),
  eng('English', Locale('en', 'US'), 'en');

  final String str;
  final Locale locale;
  final String serverCode;
  const Languages(this.str, this.locale, this.serverCode);
}

class LanguageProvider extends ChangeNotifier {
  late final SharedPreferences prefs;
  final String languageKey = 'languageKey';
  Languages state = Languages.ru;

  LanguageProvider() {
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    final langStr = prefs.getString(languageKey) ?? '';
    final lang = Languages.values.singleWhere(
      (element) => element.str == langStr,
      orElse: () => Languages.ru,
    );
    state = lang;
    notifyListeners();
  }

  Future<void> setLanguage(Languages value) async {
    await prefs.setString(languageKey, value.str);
    state = value;
    notifyListeners();
  }
}
