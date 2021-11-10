import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'chapter_list_view.dart';

class ReaderConstructor extends StatelessWidget {
  const ReaderConstructor({
    Key? key,
    required this.val,
    required this.controller,
  }) : super(key: key);
  final EbookController controller;
  final bool val;

  void loadWords(BuildContext context) async {
    final db = DBHelper();
    final data = Provider.of<BookData>(context, listen: false);
    final dataWords = Provider.of<TextData>(context, listen: false);

    final List<Map> words = await db.getWords(data.titleBook, data.language);
    for (var word in words) {
      dataWords.updateSelectedWords(word["Word"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    loadWords(context);
    final bookDataProvider = Provider.of<BookData>(context, listen: false);

    int num = 0;
    List<EpubTextContentFile> fileList = controller.fileList;

    final db = DBHelper();

    return PageView.builder(
      controller: controller.chaptersController,
      onPageChanged: (index) async {
        bookDataProvider.updateindexChapter(index);
        await db.updateLastChapterIndex(
          index,
          bookDataProvider.titleBook,
          bookDataProvider.language,
        );
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
          // return Text(fileList.elementAt(itemIndex).Content ?? "");
          return ReaderChapter(
            index: itemIndex,
            controller: controller,
            doc: fileList.elementAt(itemIndex),
            isLastChapter: isLastChapter,
          );
        }
      },
      itemCount: fileList.length + 1,
    );
  }
}
