import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'epub_service.dart';
import 'bookmark_service.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final EpubService _epubService = EpubService();
  final BookmarkService _bookmarkService = BookmarkService();
  final ScrollController _scrollController = ScrollController();

  List<String> _chapters = [];
  int _currentChapter = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    List<String> chapters =
    await _epubService.loadChapters('assets/books/orv_vol1.epub');
    int? savedIndex = await _bookmarkService.loadBookmark();

    setState(() {
      _chapters = chapters;
      _currentChapter = savedIndex ?? 0;
      _loading = false;
    });
  }

  void _saveBookmark() async {
    await _bookmarkService.saveBookmark(_currentChapter);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bookmark saved!")),
    );
  }

  void _nextChapter() {
    if (_currentChapter < _chapters.length - 1) {
      setState(() => _currentChapter++);
      _scrollController.jumpTo(0);
    }
  }

  void _prevChapter() {
    if (_currentChapter > 0) {
      setState(() => _currentChapter--);
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chapter ${_currentChapter + 1}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _saveBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Html(
          key: ValueKey(_currentChapter),
          data: _chapters[_currentChapter],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _prevChapter,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _nextChapter,
            ),
          ],
        ),
      ),
    );
  }
}
