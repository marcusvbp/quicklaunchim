// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openim/controllers/global_controller.dart';
import 'package:openim/data_storage/app_storage.dart';

enum AppLanguage {
  system,
  en,
  pt,
  es,
}

class Language extends GlobalController<AppLanguage> with ChangeNotifier {
  final AppStorage<String> storage;
  AppLanguage _current = AppLanguage.system;

  Language({
    required this.storage,
  });

  final List<String> _localeStrings = ['en', 'es', 'pt'];
  final Map<AppLanguage, String> _languageMap = {
    AppLanguage.system: Platform.localeName,
    AppLanguage.en: 'en',
    AppLanguage.es: 'es',
    AppLanguage.pt: 'pt',
  };

  String _getFirstLanguageCode(String langCode) {
    return langCode.split('_')[0];
  }

  @override
  Future<void> rehydrate() async {
    final l = await storage.retrieve();
    if (l == null) {
      _current = AppLanguage.system;
    } else {
      for (var lang in _languageMap.entries) {
        if (lang.value == l) {
          _current = lang.key;
        }
      }
    }
    notifyListeners();
  }

  @override
  void set(AppLanguage value) {
    _current = value;
    storage.save(value.name);
    notifyListeners();
  }

  Locale get current {
    final code = _getFirstLanguageCode(_languageMap[_current]!);
    if (_localeStrings.contains(code)) {
      return Locale(code, '');
    }

    return const Locale('en', '');
  }
}
