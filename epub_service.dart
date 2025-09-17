import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:flutter/services.dart' show rootBundle;

class EpubService {
  Future<List<String>> loadChapters(String path) async {
    ByteData bytes = await rootBundle.load(path);
    List<int> byteList = bytes.buffer.asUint8List();

    final book = await EpubReader.readBook(byteList);

    return book.Chapters!
        .map((chapter) => chapter.HtmlContent ?? "")
        .toList();
  }
}
