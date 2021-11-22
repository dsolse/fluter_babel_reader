import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  List<String> getBook(EpubBook book) {
    final List<String> bookContent = [];
    final List<String> spineListBooks = [];

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
    return bookContent;
  }

  List<dom.Element> getContentMenu(List<String> content) {
    final List<dom.Element> listView = content.map((e) {
      final elementsOfElement = parse(e.replaceAll("<title/>", " "));
      try {
        final elementH1 = elementsOfElement.getElementsByTagName("h1");

        if (elementH1.isNotEmpty) {
          return elementH1
              .where((element) => RegExp("[a-z]").hasMatch(element.text))
              .first;
        } else {
          final elementH2 = elementsOfElement.getElementsByTagName("h2");
          if (elementH2.isNotEmpty) {
            return elementH2
                .where((element) => RegExp("[a-z]").hasMatch(element.text))
                .first;
          } else {
            final elementH3 = elementsOfElement.getElementsByTagName("h3");
            if (elementH3.isNotEmpty) {
              return elementH3
                  .where((element) => RegExp("[a-z]").hasMatch(element.text))
                  .first;
            } else {
              final elementsTitle =
                  elementsOfElement.getElementsByTagName("title");
              if (elementsTitle.isNotEmpty &&
                  elementsTitle.first.text.length < 100) {
                return elementsTitle
                    .where((element) => RegExp("[a-z]").hasMatch(element.text))
                    .first;
              } else {
                final elementP = elementsOfElement
                    .getElementsByTagName("p")
                    .where((element) => RegExp("[a-z]").hasMatch(element.text));
                if (elementP.isNotEmpty && elementP.first.text.length < 50) {
                  return elementP.first;
                } else {
                  return dom.Element.html("<p>None</p>");
                }
              }
            }
          }
        }
      } catch (er) {
        return dom.Element.html("<p>None</p>");
      }
    }).toList();
    return listView;
  }

  Future<EbookData> getEbook(BuildContext context) async {
    final db = DBHelper();

    final EpubBook book =
        await EpubReader.readBook(File(epubBook.locationBook!).readAsBytes());

    final List<String> contentBook = getBook(book);

    final List<dom.Element> contentMenu = getContentMenu(contentBook);

    final position =
        await addBook(epubBook.title ?? "None", epubBook.language ?? "en", db);
    final providerData = Provider.of<BookData>(context, listen: false);
    final providerDataT = Provider.of<TextData>(context, listen: false);

    providerData.registerLanguage(epubBook.language ?? "en");
    providerDataT.registerLanguage(epubBook.language ?? "en");
    providerData.registerTitle(epubBook.title ?? "Untitle");
    providerDataT.registerToTranslate("en");
    final result = EbookData.fromJson({
      "ebook": book,
      "position": position,
      "contentBook": contentBook,
      "contentMenu": contentMenu,
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EbookData>(
      future: getEbook(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
        } else {
          return const Material(
              child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class EbookReaderScafold extends StatefulWidget {
  const EbookReaderScafold({
    Key? key,
    required this.data,
  }) : super(key: key);
  final EbookData data;

  @override
  State<EbookReaderScafold> createState() => _EbookReaderScafoldState();
}

class _EbookReaderScafoldState extends State<EbookReaderScafold> {
  late EbookController controller;
  bool valueS = true;

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
  void initState() {
    controller = EbookController(
      lastAlineo: widget.data.position!.lastAlineo!,
      lastChapterindex: widget.data.position!.lastChapter!,
      lastChapterScroll: widget.data.position!.lastIndex!,
      chaptersController:
          PageController(initialPage: widget.data.position!.lastChapter!),
      document: widget.data.ebook,
    );
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _keyScafold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final _color = Colors.white;

    return Scaffold(
      key: _keyScafold,
      resizeToAvoidBottomInset: false,

      //   title: Switch(
      //     value: valueS,
      //     onChanged: (val) => setState(() {
      //       valueS = val;
      //     }),
      //   ),
      endDrawer: Drawer(
        child: DrawerReader(
          dark: MediaQuery.of(context).platformBrightness == Brightness.dark,
          controller: controller,
          listFiles: widget.data.contentMenu,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.00),
            child: ReaderConstructor(
              controller: controller,
              val: valueS,
              bookContent: widget.data.contentBook,
            ),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Tooltip(
              message: MaterialLocalizations.of(context).openAppDrawerTooltip,
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.elliptical(10, 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.5),
                        blurRadius: 1.0,
                      ),
                    ]),
                child: InkWell(
                  splashColor: Theme.of(context).colorScheme.background,
                  onTap: () => _keyScafold.currentState!.openEndDrawer(),
                  child: Icon(
                    Icons.menu,
                    color: _color,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            child: Tooltip(
              message: MaterialLocalizations.of(context).backButtonTooltip,
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.elliptical(10, 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.5),
                        blurRadius: 1.0,
                      ),
                    ]),
                child: InkWell(
                  splashColor: Theme.of(context).colorScheme.background,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: _color,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
