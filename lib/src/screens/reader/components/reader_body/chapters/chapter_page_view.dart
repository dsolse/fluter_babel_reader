import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'chapter_list_view.dart';

class ReaderConstructor extends StatelessWidget {
  ReaderConstructor({
    Key? key,
    required this.val,
    required this.controller,
  }) : super(key: key);
  final EbookController controller;

  final bool val;
  final List<String> bookContent = [];

  void loadWords(BuildContext context) async {
    final db = DBHelper();
    final data = Provider.of<BookData>(context, listen: false);
    final dataWords = Provider.of<TextData>(context, listen: false);

    final List<Map> words = await db.getWords(data.titleBook, data.language);
    for (var word in words) {
      dataWords.updateSelectedWords(word["Word"]);
    }
  }

  void getBook() async {
    final List<String> spineListBooks = [];

    final EpubBook book = controller.document;
    if (book.Schema?.Package?.Spine?.Items != null) {
      for (var n in book.Schema!.Package!.Spine!.Items!) {
        if (n.IdRef != null) {
          spineListBooks.add(n.IdRef!);
        }
      }

      if (book.Schema?.Package?.Manifest?.Items != null) {
        final List<String> bookContentRef = [];
        for (var bRef in spineListBooks) {
          String? bookReff = book.Schema?.Package?.Manifest?.Items
              ?.where((element) => element.Id == bRef)
              .first
              .Href;
          if (bookReff != null) {
            bookContentRef.add(bookReff);
          }
        }
        final Map<String, EpubTextContentFile>? mapBook = book.Content?.Html;
        for (var bookRefFinal in bookContentRef) {
          final boolMap = mapBook?[bookRefFinal]?.Content;
          if (boolMap != null) {
            bookContent.add(boolMap);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getBook();
    loadWords(context);
    final bookDataProvider = Provider.of<BookData>(context, listen: false);

    int num = 0;
    List<String> fileList = controller.fileList;

    final db = DBHelper();

    return PageView.builder(
      controller: controller.chaptersController,
      onPageChanged: (index) async {
        if (index != bookContent.length) {
          bookDataProvider.updateindexChapter(index);
          await db.updateLastChapterIndex(
            index,
            bookDataProvider.titleBook,
            bookDataProvider.language,
          );
        }
      },
      itemBuilder: (BuildContext context, int itemIndex) {
        if (itemIndex == fileList.length) {
          return const Center(
            child: Text("End"),
          );
        } else {
          late bool isLastChapter;
          if (controller.lastChapterindex == itemIndex && num == 0) {
            isLastChapter = true;
            num++;
          } else {
            isLastChapter = false;
          }
          if (val) {
            return ReaderChapter(
              index: itemIndex,
              controller: controller,
              doc: fileList.elementAt(itemIndex),
              isLastChapter: isLastChapter,
            );
          } else {
            return SingleChildScrollView(
              child: SelectableText(
                  // fileList.elementAt(itemIndex).Content
                  bookContent[itemIndex]),
            );
          }
        }
      },
      itemCount: bookContent.length + 1,
    );
  }
}
