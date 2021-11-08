import 'dart:convert';
import 'dart:io';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:flutter/src/widgets/image.dart' as image;
import 'package:final_babel_reader_app/src/screens/reader/epub_reader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListBooks extends StatelessWidget {
  const ListBooks({Key? key, required this.listBooks, required this.callback})
      : super(key: key);
  final List<Map> listBooks;
  final Function callback;

  List<Widget> getChips(BuildContext context, List<String>? langs) {
    List<Widget> chips = [];
    for (var language in langs ?? []) {
      if (language != null) {
        chips.add(
          Chip(
            label: Text(
              language,
              style: TextStyle(color: Theme.of(context).backgroundColor),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    if (listBooks.isEmpty) {
      return const Center(
        child: Text("None book. Add one"),
      );
    } else {
      final listBooksData =
          listBooks.map((e) => MapEbookData.fromJson(e)).toList();
      return SingleChildScrollView(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: listBooks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Theme.of(context).backgroundColor,
                elevation: 5,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EbookReader(
                        ebook: listBooksData[index],
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            child: (listBooksData[index].locationCover != null)
                                ? image.Image.file(
                                    File(listBooksData[index].locationCover!))
                                : image.Image.asset("assets/nonImageCover.png"),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                listBooksData[index].title ?? "Untitled",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20),
                              ),
                              subtitle: Text(
                                "Author: ${listBooksData[index].author ?? "Anounymous"}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 17),
                              ),
                              dense: true,
                            ),
                            Row(
                              children: getChips(context,
                                  [listBooksData[index].language ?? "en"]),
                            ),
                            Card(
                              elevation: 5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      SharedPreferences sharedPreferences =
                                          await SharedPreferences.getInstance();
                                      final List<String>? books =
                                          sharedPreferences
                                              .getStringList("books");
                                      if (books != null) {
                                        books.remove(
                                            json.encode(listBooks[index]));

                                        sharedPreferences.setStringList(
                                            'books', books);

                                        callback(books
                                            .map((e) => json.decode(e) as Map)
                                            .toList());
                                        if (listBooksData[index].locationBook !=
                                            null) {
                                          final file = File(listBooksData[index]
                                              .locationBook!);
                                          if (file.existsSync()) {
                                            file.deleteSync();
                                          }
                                        }
                                        if (listBooksData[index]
                                                .locationCover !=
                                            null) {
                                          final fileImage = File(
                                              listBooksData[index]
                                                  .locationCover!);
                                          if (fileImage.existsSync()) {
                                            fileImage.deleteSync();
                                          }
                                        }
                                      }
                                    },
                                    icon: const Tooltip(
                                      message: "Delete book from library",
                                      child: Icon(Icons.delete),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // SharedPreferences sharedPreferences =
                                      //     await SharedPreferences.getInstance();
                                      // final List<String>? books =
                                      //     sharedPreferences
                                      //         .getStringList("books");
                                      // if (books != null) {
                                      //   books.remove(
                                      //       json.encode(listBooks[index]));
                                      //   sharedPreferences.setStringList(
                                      //       'books', books);
                                      //   callback(books);
                                      // }
                                    },
                                    icon: const Icon(Icons.favorite),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
