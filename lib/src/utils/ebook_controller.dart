import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';

class EbookController {
  final PageController chaptersController;
  final double lastAlineo;
  final int lastChapterScroll;
  final int lastChapterindex;
  EpubBook document;
  List<String> fileList;
  EbookController(
      {required this.lastChapterScroll,
      required this.lastAlineo,
      required this.lastChapterindex,
      required this.document,
      required this.chaptersController,
      required this.fileList});
  get chapterController => chaptersController;

  scrollToChapter(int index) {
    chaptersController.jumpToPage(index);
  }
}
