import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:epubx/epubx.dart';
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

  List<EpubChapter> _chapters = [];
  int _currentChapter = 0;
  bool _loading = true;
  String? _errorMessage;
  double _fontSize = 16.0;

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
    try {
      final chapters = await _epubService.loadChapters('assets/books/orv_vol1.epub');

      if (chapters.isEmpty) {
        setState(() {
          _errorMessage = "No chapters found in the book";
          _loading = false;
        });
        return;
      }

      final bookmark = await _bookmarkService.loadBookmark();

      setState(() {
        _chapters = chapters;
        _currentChapter = bookmark?.chapterIndex ?? 0;
        _loading = false;
      });

      // Restore scroll position after frame is rendered
      if (bookmark != null && bookmark.scrollPosition > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(bookmark.scrollPosition);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load book: $e";
        _loading = false;
      });
    }
  }

  Future<void> _saveBookmark() async {
    final scrollPosition = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    await _bookmarkService.saveBookmark(
      _currentChapter,
      scrollPosition: scrollPosition,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bookmark saved!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextChapter() {
    if (_currentChapter < _chapters.length - 1) {
      setState(() => _currentChapter++);
      _scrollController.jumpTo(0);
      _saveBookmark();
    }
  }

  void _prevChapter() {
    if (_currentChapter > 0) {
      setState(() => _currentChapter--);
      _scrollController.jumpTo(0);
      _saveBookmark();
    }
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _chapters.length,
        itemBuilder: (context, index) {
          final chapter = _chapters[index];
          final title = chapter.Title ?? 'Chapter ${index + 1}';

          return ListTile(
            leading: Icon(
              index == _currentChapter ? Icons.book : Icons.book_outlined,
              color: index == _currentChapter ? Colors.blue : null,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: index == _currentChapter ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() => _currentChapter = index);
              _scrollController.jumpTo(0);
              Navigator.pop(context);
              _saveBookmark();
            },
          );
        },
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Font Size:'),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                    },
                  ),
                ),
                Text(_fontSize.round().toString()),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _errorMessage = null;
                    });
                    _loadBook();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chapterTitle = _chapters[_currentChapter].Title ??
        'Chapter ${_currentChapter + 1}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapterTitle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showChapterList,
            tooltip: 'Chapters',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _saveBookmark,
            tooltip: 'Save Bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Html(
          key: ValueKey(_currentChapter),
          data: _epubService.getChapterContent(_currentChapter, _chapters),
          style: {
            "body": Style(
              fontSize: FontSize(_fontSize),
              lineHeight: const LineHeight(1.6),
            ),
            "p": Style(
              margin: Margins.only(bottom: 12),
            ),
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentChapter > 0 ? _prevChapter : null,
              tooltip: 'Previous Chapter',
            ),
            Text(
              '${_currentChapter + 1} / ${_chapters.length}',
              style: const TextStyle(fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentChapter < _chapters.length - 1 ? _nextChapter : null,
              tooltip: 'Next Chapter',
            ),
          ],
        ),
      ),
    );
  }
}
