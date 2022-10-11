import 'package:flutter/material.dart';
import 'package:openim/controllers/global_controller.dart';
import 'package:openim/data_storage/app_storage.dart';
import 'package:openim/models/history.dart';

class MessengerValue extends GlobalController<InstantMessenger>
    with ChangeNotifier {
  final AppStorage<String> storage;

  MessengerValue({required this.storage});

  InstantMessenger _messenger = InstantMessenger.whatsapp;

  get messenger => _messenger;

  @override
  void set(InstantMessenger value) async {
    _messenger = value;
    await storage.save(value.name);
    notifyListeners();
  }

  @override
  Future<void> rehydrate() async {
    final m = await storage.retrieve();
    _messenger = InstantMessenger.values.firstWhere((e) => e.name == m,
        orElse: () => InstantMessenger.whatsapp);
    notifyListeners();
  }
}
