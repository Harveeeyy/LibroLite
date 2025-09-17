# 📚 LibroLite

LibroLite is a simple Flutter EPUB Reader built as a personal summer refresher project with the help of AI to practice Flutter development, state management, and working with external packages like epubx and flutter_html.

# ✨ Features

* 📖 Load and parse .epub files from assets

* 🧭 Navigate between chapters

* 🔖 Save and load bookmarks using shared_preferences

* 🖼 Render EPUB content with flutter_html

* 📱 Works on Android Emulator (tested with Pixel 9 Pro via Android Studio)

# 📂 Project Structure
lib/
├── main.dart                 
├── reader_page.dart         
├── chapter_page.dart         
├── epub_service.dart       
└── bookmark_service.dart   
assets/
└── books/                  

# 🛠 Dependencies

* epubx
 – EPUB parsing
* flutter_html
 – render HTML content from EPUB
* shared_preferences
 – store bookmarks

# 🚀 Getting Started
1. Clone the repo:
git clone https://github.com/YOUR-USERNAME/epub_reader.git
cd epub_reader
2. Get packages:
   flutter pub get
3. flutter:
  assets:
    - assets/books/orv_vol1.epub
4. flutter run


