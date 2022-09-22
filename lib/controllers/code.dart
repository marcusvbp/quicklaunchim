import 'package:flutter/material.dart';
import 'package:openim/controllers/global_controller.dart';

import '../data_storage/app_storage.dart';

class CodeValue extends GlobalController<String> with ChangeNotifier {
  final AppStorage<String> storage;

  CodeValue({required this.storage});

  String _code = '';

  get code => _code;

  @override
  void set(String value) async {
    _code = value;
    await storage.save(value);
    notifyListeners();
  }

  @override
  Future<void> rehydrate() async {
    _code = await storage.retrieve() ?? '';
    notifyListeners();
  }
}
