// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:quicklaunchim/controllers/global_controller.dart';
import 'package:quicklaunchim/data_storage/app_storage.dart';
import 'package:universal_io/io.dart';

class LanguageController extends GlobalController<Locale> with ChangeNotifier {
  final AppStorage<String> storage;

  late Locale _current;

  final List<Locale> _locales = [
    const Locale('en', 'US'),
    const Locale('es', 'ES'),
    const Locale('pt', 'BR'),
  ];

  LanguageController({
    required this.storage,
  });

  Locale _getSystemLocale(String systemLangCode) {
    final List<String> parts = systemLangCode.replaceAll('-', '_').split('_');
    final langCode = Locale(parts[0], parts[1]);
    if (!_locales.map((e) => e.languageCode).contains(langCode.languageCode)) {
      return const Locale('en', 'US');
    }
    return langCode;
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
