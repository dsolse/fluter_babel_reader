import 'package:epubx/epubx.dart';

class DBData {
  double? lastAlineo = 0.0;
  int? lastChapter = 0;
  int? lastIndex = 0;

  DBData(
      {required this.lastChapter,
      required this.lastIndex,
      required this.lastAlineo});

  DBData.fromJson(Map<dynamic, dynamic> jsondata) {
    lastAlineo = jsondata['Alineo'] ?? 0.0;
    lastChapter = jsondata['LastChapterIndex'] ?? 0;
    lastIndex = jsondata['LastChapterScroll'] ?? 0;
  }
}

class EbookData {
  late EpubBook ebook;
  DBData? position;

  EbookData({required this.position, required this.ebook});

  EbookData.fromJson(Map<dynamic, dynamic> map) {
    ebook = map["ebook"];
    position = map["position"];
  }
}

class MapEbookData {
  String? title;
  String? author;
  String? language;
  String? locationBook;
  String? locationCover;
  MapEbookData(
      {required this.title,
      required this.author,
      required this.language,
      required this.locationBook,
      required this.locationCover});

  MapEbookData.fromJson(Map<dynamic, dynamic> jsondata) {
    title = jsondata['title'];
    author = jsondata['author'];
    language = jsondata['language'];
    locationBook = jsondata['locationBook'];
    locationCover = jsondata['locationCover'];
  }
}