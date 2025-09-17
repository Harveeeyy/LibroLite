import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  final String _key = "bookmark_chapter";

  Future<void> saveBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
  }

  Future<int?> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }
}
