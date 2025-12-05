import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:flutter/services.dart' show rootBundle;

class EpubService {
  EpubBook? _cachedBook;

  /// Load chapters from EPUB file
  Future<List<EpubChapter>> loadChapters(String path) async {
    try {
      // Load from cache if available
      if (_cachedBook == null) {
        ByteData bytes = await rootBundle.load(path);
        List<int> byteList = bytes.buffer.asUint8List();
        _cachedBook = await EpubReader.readBook(byteList);
      }

      // Return empty list if no chapters found
      if (_cachedBook?.Chapters == null || _cachedBook!.Chapters!.isEmpty) {
        return [];
      }

      return _cachedBook!.Chapters!;
    } catch (e) {
      print('Error loading EPUB: $e');
      rethrow;
    }
  }

  /// Get chapter HTML content by index
  String getChapterContent(int index, List<EpubChapter> chapters) {
    if (index < 0 || index >= chapters.length) {
      return '<p>Chapter not found</p>';
    }
    return chapters[index].HtmlContent ?? '<p>Empty chapter</p>';
  }

  /// Get book metadata
  Future<Map<String, String?>> getBookMetadata(String path) async {
    if (_cachedBook == null) {
      await loadChapters(path);
    }

    return {
      'title': _cachedBook?.Title,
      'author': _cachedBook?.Author,
      // Note: Description property may not exist in epubx 4.0.0
      // You can access it through Schema?.Package?.Metadata?.Descriptions if needed
    };
  }

  /// Clear cached book (useful for loading different books)
  void clearCache() {
    _cachedBook = null;
  }
}
