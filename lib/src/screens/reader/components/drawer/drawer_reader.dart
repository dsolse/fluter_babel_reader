import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'font_color_menu/font_color_body.dart';

class DrawerReader extends StatelessWidget {
  const DrawerReader(
      {Key? key,
      required this.controller,
      required this.dark,
      required this.listFiles})
      : super(key: key);
  final EbookController controller;
  final bool dark;
  final List<dom.Element> listFiles;
  static List<Tab> tabIcons = const [
    Tab(
      icon: Icon(MdiIcons.formatListBulleted),
    ),
    Tab(
      icon: Icon(MdiIcons.greasePencil),
    )
  ];

  Future<List<Map>> getWords(BuildContext context) async {
    final dataBook = Provider.of<BookData>(context, listen: false);
    final db = DBHelper();
    final List<Map> words =
        await db.getWords(dataBook.titleBook, dataBook.language);
    return words;
  }

  Future<void> deleteWord(BuildContext context, String word) async {
    final dataBook = Provider.of<BookData>(context, listen: false);
    final db = DBHelper();
    await db.deleteWords(dataBook.titleBook, word, dataBook.language);
  }

  @override
  Widget build(BuildContext context) {
    List<Map> booksTitles = [];
    int valueTitle = 0;
    for (var titleR in listFiles) {
      if (titleR.localName == "title") {
        final String title = titleR.text;
        booksTitles.add({"titleInt": valueTitle, "titleName": title});
      }
      valueTitle++;
    }

    final data = Provider.of<TextData>(context, listen: false);
    final dataBook = Provider.of<BookData>(context, listen: false);

    void changeColor(Color color) {
      if (dark) {
        data.updateTextColorDM(color);
      } else {
        data.updateTextColorLM(color);
      }
    }

    void changeFontFamily(fontFamily) {
      data.updateFontFamily(fontFamily);
    }

    void changeFontSize(double fontSize) {
      data.updateFontSize(fontSize);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: tabIcons),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(HeroPageView(
                    builder: (context) => FontMenu(
                          callbackFontFamily: changeFontFamily,
                          currentFontFamily: data.fontFamily,
                          callbackColor: changeColor,
                          value: data.fontSize,
                          callbackFont: changeFontSize,
                          originalLanguage: dataBook.language,
                          translationLanguage: dataBook.toTranslate,
                          changeOriginalLanguage: (String newLanguage) {
                            dataBook.registerLanguage(newLanguage);
                          },
                          changeTranslationLanguage: (newTranslation) {
                            dataBook.registerToTranslate(newTranslation);
                          },
                        )));
              },
              icon: const Icon(MdiIcons.formatFont),
            )
          ],
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: booksTitles.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 10.0,
                          maxHeight: 60.0,
                        ),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Expanded(
                      flex: 14,
                      child: ListTile(
                        leading: Text(
                          "${index + 1}/${booksTitles.length}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(
                          booksTitles.elementAt(index)["titleName"],
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.scrollToChapter(
                              booksTitles.elementAt(index)["titleInt"]);
                        },
                      ),
                    )
                  ],
                );
              },
            ),
            FutureBuilder(
              future: getWords(context),
              initialData: const [],
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator.adaptive();
                  default:
                    if (snapshot.hasError) {
                      return const Center(child: Text("No words for now"));
                    } else {
                      if (snapshot.data.isEmpty) {
                        return const Center(child: Text("No words"));
                      } else {
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: IconButton(
                                  onPressed: () async {
                                    deleteWord(
                                        context,
                                        snapshot.data[index]["Word"]
                                            .toString());
                                  },
                                  icon: const Tooltip(
                                    message: "Delete word",
                                    child: Icon(Icons.delete),
                                  )),
                              title:
                                  Text(snapshot.data[index]["Word"].toString()),
                              subtitle:
                                  Text(snapshot.data[index]["Translation"]),
                            );
                          },
                          itemCount: snapshot.data.length,
                        );
                      }
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
