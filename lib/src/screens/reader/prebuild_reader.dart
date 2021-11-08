import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import 'components/drawer/drawer_reader.dart';
import 'components/reader_body/chapters/chapter_page_view.dart';

class EbookReaderFuture extends StatelessWidget {
  const EbookReaderFuture({Key? key, required this.epubBook}) : super(key: key);
  final MapEbookData epubBook;

  Future<DBData> addBook(String title, String language, DBHelper db) async {
    if (await db.bookExists(title, language)) {
      var indexes = await db.getPosition(title, language);
      return DBData.fromJson(indexes);
    } else {
      await db.addBook(title, language);
      return DBData.fromJson(
          {"LastChapterIndex": 0, "LastChapterScroll": 0, "Alineo": 0.0});
    }
  }

  Future<EbookData> getEbook(BuildContext context) async {
    final db = DBHelper();

    final EpubBook book =
        await EpubReader.readBook(File(epubBook.locationBook!).readAsBytes());

    final position =
        await addBook(epubBook.title ?? "None", epubBook.language ?? "en", db);
    final providerData = Provider.of<BookData>(context, listen: false);
    providerData.registerLanguage(epubBook.language ?? "en");
    providerData.registerTitle(epubBook.title ?? "Untitle");
    providerData.registerToTranslate("en");
    final result = EbookData.fromJson({"ebook": book, "position": position});

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<EbookData>(
        future: getEbook(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text(
                        "There was something wrong, the books is unreadable: ${snapshot.error}"),
                  ),
                );
              } else {
                return EbookReaderScafold(data: snapshot.data!);
              }
          }
        },
      ),
    );
  }
}

class EbookReaderScafold extends StatelessWidget {
  const EbookReaderScafold({
    Key? key,
    required this.data,
  }) : super(key: key);
  final EbookData data;

//   @override
//   State<EbookReaderScafold> createState() => _EbookReaderScafoldState();
// }

// class _EbookReaderScafoldState extends State<EbookReaderScafold> {
  // late EbookController controller;
  // late List<dom.Element> listView;
  // bool valueS = true;
  // // @override
  // // void initState() {
  //   // print(widget.data.ebook.Content?.Html?.values.first.FileName);
  //   controller = EbookController(
  //       lastAlineo: widget.data.position!.lastAlineo!,
  //       lastChapterindex: widget.data.position!.lastChapter!,
  //       lastChapterScroll: widget.data.position!.lastIndex!,
  //       chaptersController:
  //           PageController(initialPage: widget.data.position!.lastChapter!),
  //       document: widget.data.ebook,
  //       fileList: List.from(
  //           widget.data.ebook.Content?.Html?.values ?? const Iterable.empty()));

  //   listView = controller.fileList.map((e) {
  //     final elements = getElements(parse(e.Content).body!.children);
  //     // print(parse(e.Content, encoding: "utf8").outerHtml);
  //     if (elements.isNotEmpty) {
  //       if (elements.first.getElementsByTagName("img").isNotEmpty &&
  //           elements.length > 1) {
  //         return elements.elementAt(1);
  //       } else {
  //         if (elements.first.children.length > 1) {
  //           return elements.first.children.first;
  //         }
  //         return elements.first;
  //       }
  //     } else {
  //       final elements2 =
  //           getElements(parse(e.Content, encoding: "utf8").children);
  //       if (elements2.first.getElementsByTagName("img").isNotEmpty &&
  //           elements2.length > 1) {
  //         return elements2.elementAt(1);
  //       } else {
  //         return elements2.first;
  //       }
  //     }
  //   }).toList();
  // super.initState();
  // }

  List<dom.Element> getElements(List<dom.Element> elements) {
    List<dom.Element> paragraghs = [];

    for (final node in elements) {
      if (node.getElementsByTagName("p").length > 1) {
        paragraghs.addAll(getElements(node.children));
      } else {
        paragraghs.add(node);
      }
    }

    return paragraghs;
  }

  @override
  Widget build(BuildContext context) {
    late EbookController controller;
    late List<dom.Element> listView;
    bool valueS = true;
    // @override
    // void initState() {
    // print(widget.data.ebook.Content?.Html?.values.first.FileName);
    controller = EbookController(
        lastAlineo: data.position!.lastAlineo!,
        lastChapterindex: data.position!.lastChapter!,
        lastChapterScroll: data.position!.lastIndex!,
        chaptersController:
            PageController(initialPage: data.position!.lastChapter!),
        document: data.ebook,
        fileList: List.from(
            data.ebook.Content?.Html?.values ?? const Iterable.empty()));

    listView = controller.fileList.map((e) {
      final elements = getElements(parse(e.Content).body!.children);
      // print(parse(e.Content, encoding: "utf8").outerHtml);
      if (elements.isNotEmpty) {
        if (elements.first.getElementsByTagName("img").isNotEmpty &&
            elements.length > 1) {
          return elements.elementAt(1);
        } else {
          if (elements.first.children.length > 1) {
            return elements.first.children.first;
          }
          return elements.first;
        }
      } else {
        final elements2 =
            getElements(parse(e.Content, encoding: "utf8").children);
        if (elements2.first.getElementsByTagName("img").isNotEmpty &&
            elements2.length > 1) {
          return elements2.elementAt(1);
        } else {
          return elements2.first;
        }
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BookData>(
          builder: (context, value, _) {
            final title = value.titleBook;
            return Text(title);
            // return AnimatedSwitcher(
            //   duration: const Duration(milliseconds: 500),
            //   transitionBuilder: (Widget child, Animation<double> animation) {
            //     return ScaleTransition(child: child, scale: animation);
            //   },
            //   child: Text(
            //     title,
            //     key: ValueKey<String>(title),
            //   ),
            // );
          },
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      endDrawer: Drawer(
        child: DrawerReader(
          dark: MediaQuery.of(context).platformBrightness == Brightness.dark,
          controller: controller,
          listFiles: listView,
        ),
      ),
      body: ReaderConstructor(controller: controller, val: valueS),
    );
  }
}