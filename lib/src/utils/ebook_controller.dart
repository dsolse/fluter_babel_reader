import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';

class EbookController {
  final PageController chaptersController;
  final double lastAlineo;
  final int lastChapterScroll;
  final int lastChapterindex;
  EpubBook document;

  EbookController({
    required this.lastChapterScroll,
    required this.lastAlineo,
    required this.lastChapterindex,
    required this.document,
    required this.chaptersController,
  });
  get chapterController => chaptersController;

  scrollToChapter(int index) {
    chaptersController.jumpToPage(index);
  }
}
