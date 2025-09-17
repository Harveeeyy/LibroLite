import 'package:flutter/material.dart';
import 'reader_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPUB Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReaderPage(),
    );
  }
}
