import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _chapterKey = "bookmark_chapter";
  static const String _scrollKey = "bookmark_scroll";
  static const String _bookPathKey = "last_book_path";

  /// Save bookmark with chapter index and scroll position
  Future<void> saveBookmark(int chapterIndex, {double scrollPosition = 0.0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_chapterKey, chapterIndex);
      await prefs.setDouble(_scrollKey, scrollPosition);
    } catch (e) {
      print('Error saving bookmark: $e');
    }
  }

  /// Load bookmark (returns chapter index and scroll position)
  Future<BookmarkData?> loadBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chapter = prefs.getInt(_chapterKey);
      final scroll = prefs.getDouble(_scrollKey) ?? 0.0;

      if (chapter != null) {
        return BookmarkData(chapterIndex: chapter, scrollPosition: scroll);
      }
    } catch (e) {
      print('Error loading bookmark: $e');
    }
    return null;
  }

  /// Save last opened book path
  Future<void> saveLastBookPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookPathKey, path);
  }

  /// Get last opened book path
  Future<String?> getLastBookPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookPathKey);
  }

  /// Clear all bookmarks
  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chapterKey);
    await prefs.remove(_scrollKey);
  }
}

/// Data class for bookmark information
class BookmarkData {
  final int chapterIndex;
  final double scrollPosition;

  BookmarkData({
    required this.chapterIndex,
    this.scrollPosition = 0.0,
  });
}
