import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:flutter/material.dart';

class BookData with ChangeNotifier {
  late String _title;
  late String _language;
  late String _toTranslate;
  late String _bookTitle;
  late double _alignment;
  late int _indexChapter;
  late int _indexScroll;

  BookData() {
    _title = "CoverData";
    _language = "en";
    _toTranslate = "en";
    _bookTitle = "";
    _alignment = 0.0;
    _indexChapter = 0;
    _indexScroll = 0;
  }
  String get title => _title;
  double get alignment => _alignment;
  int get indexChapter => _indexChapter;
  int get indexScroll => _indexScroll;
  String get titleBook => _bookTitle;
  String get language => _language;
  String get toTranslate => _toTranslate;

  registerTitle(String titleBook) {
    _bookTitle = titleBook;
    notifyListeners();
  }

  registerToTranslate(String lang) {
    _toTranslate = lang;
    notifyListeners();
  }

  registerLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  updateindexScroll(int newIndexScroll) {
    _indexScroll = newIndexScroll;
    notifyListeners();
  }

  updateindexChapter(int newIndexChapter) {
    _indexChapter = newIndexChapter;
    notifyListeners();
  }

  updateAlignment(double newAlignment) {
    _alignment = newAlignment;
    notifyListeners();
  }

  @override
  void dispose() {
    final db = DBHelper();
    db.updateLastChapterScroll(indexScroll, titleBook, language);
    db.updateLastChapterAlineo(alignment, titleBook, language);
    print(indexScroll);
    print(alignment);

    super.dispose();
  }
}
