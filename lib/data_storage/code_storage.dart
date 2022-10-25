import 'package:quicklaunchim/data_storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeStorage extends AppStorage<String> {
  @override
  Future<void> save(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('code', value);
  }

  @override
  Future<String?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('code');
  }
}
