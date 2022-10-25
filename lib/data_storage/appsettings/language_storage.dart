import 'package:quicklaunchim/data_storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageStorage extends AppStorage<String> {
  @override
  Future<String?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language');
  }

  @override
  Future<void> save(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', value);
  }
}
