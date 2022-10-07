import 'package:flutter/material.dart';
import 'package:openim/controllers/global_controller.dart';
import 'package:openim/data_storage/app_storage.dart';

class ThemeController extends GlobalController<ThemeMode> with ChangeNotifier {
  final AppStorage<String> storage;

  ThemeController({required this.storage});

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  Future<void> rehydrate() async {
    final t = await storage.retrieve();
    if (t != null) {
      _themeMode = ThemeMode.values.firstWhere((element) => element.name == t);
      notifyListeners();
    }
  }

  @override
  void set(ThemeMode value) async {
    _themeMode = value;
    await storage.save(value.name);
    notifyListeners();
  }

  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(),
    appBarTheme: const AppBarTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
    ),
  );
}
