import 'package:quicklaunchim/data_storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage extends AppStorage<List<String>> {
  @override
  Future<void> save(List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', value);
  }

  @override
  Future<List<String>?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history');
  }
}
