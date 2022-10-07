// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:openim/controllers/global_controller.dart';
import 'package:openim/data_storage/app_storage.dart';

class LanguageController extends GlobalController<Locale> with ChangeNotifier {
  final AppStorage<String> storage;

  late Locale _current;

  final List<Locale> _locales = [
    const Locale('en', ''),
    const Locale('es', ''),
    const Locale('pt', ''),
  ];

  LanguageController({
    required this.storage,
  });

  Locale _getSystemLocale(String systemLangCode) {
    final langCode = systemLangCode.split('_')[0];
    if (!_locales.map((e) => e.languageCode).contains(langCode)) {
      return const Locale('en', '');
    }
    return Locale(langCode, '');
  }

  @override
  Future<void> rehydrate() async {
    final l = await storage.retrieve();
    if (l == null) {
      _current = _getSystemLocale(Platform.localeName);
    } else {
      for (var lang in _locales) {
        if (lang.languageCode == l) {
          _current = lang;
        }
      }
    }
    notifyListeners();
  }

  @override
  Future<void> set(Locale value) async {
    _current = value;
    storage.save(value.languageCode);
    await LocalJsonLocalization.delegate.load(value);
    notifyListeners();
  }

  Locale get current => _current;

  List<Locale> get supportedLocales => _locales;
}
