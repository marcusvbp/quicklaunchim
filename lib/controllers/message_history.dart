import 'package:flutter/material.dart';
import 'package:openim/controllers/global_controller.dart';
import 'package:openim/data_storage/app_storage.dart';
import 'package:openim/models/history.dart';

class MessageHistory extends GlobalController<History> with ChangeNotifier {
  final AppStorage<List<String>> storage;

  MessageHistory({required this.storage});

  final List<History> _items = [];

  List<History> get items => _items;

  Future<void> _updateStorage() async {
    await storage.save(_items.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> set(History value) async {
    _items.add(value);
    await _updateStorage();
    notifyListeners();
  }

  Future<void> remove(History item) async {
    _items.remove(item);
    await _updateStorage();
    notifyListeners();
  }

  @override
  Future<void> rehydrate() async {
    final List<String>? data = await storage.retrieve();
    if (data != null && data.isNotEmpty) {
      _items.clear();
      _items.addAll(data.map((e) => History.fromJson(e)).toList());
      notifyListeners();
    }
  }
}
