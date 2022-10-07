import 'package:openim/data_storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage extends AppStorage<String> {
  @override
  Future<String?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme');
  }

  @override
  Future<void> save(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', value);
  }
}
