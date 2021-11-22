import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:flutter/src/widgets/image.dart' as image;
import 'package:final_babel_reader_app/src/screens/reader/epub_reader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListBooks extends StatelessWidget {
  const ListBooks({Key? key, required this.listBooks, required this.callback})
      : super(key: key);
  final List<Map> listBooks;
  final Function callback;

  List<Widget> getFlag(BuildContext context, List<String>? langs) {
    List<Widget> chips = [];
    final RoundedRectangleBorder _shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0));
    const Color fontColor = Colors.white;
    final Color chipColor = Theme.of(context).colorScheme.primary;
    for (var language in langs ?? []) {
      if (language != null) {
        if (language == "en") {
          chips.add(
            Chip(
              label: const Text("English"),
              shape: _shape,
              elevation: 3,
              backgroundColor: chipColor,
              labelStyle: const TextStyle(color: fontColor),
            ),
          );
        } else if (language == "ru") {
          chips.add(Chip(
            shape: _shape,
            label: const Text("Russian"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        } else if (language == "fr") {
          chips.add(Chip(
            shape: _shape,
            label: const Text("French"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        } else if (language == "de") {
          chips.add(Chip(
            shape: _shape,
            label: const Text("German"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        } else if (language == "es") {
          chips.add(Chip(
            shape: _shape,
            label: const Text("Spanish"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        } else if (language == "it") {
          chips.add(Chip(
            shape: _shape,
            label: const Text("Italian"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        } else {
          chips.add(Chip(
            shape: _shape,
            label: const Text("English"),
            elevation: 3,
            backgroundColor: chipColor,
            labelStyle: const TextStyle(color: fontColor),
          ));
        }
      }
    }
    return chips;
  }

  Future<void> deleteBook(List<MapEbookData> listBooksData, int index) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String>? books = sharedPreferences.getStringList("books");
    if (books != null) {
      books.remove(json.encode(listBooks[index]));

      sharedPreferences.setStringList('books', books);

      callback(books.map((e) => json.decode(e) as Map).toList());
      if (listBooksData[index].locationBook != null) {
        final file = File(listBooksData[index].locationBook!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      if (listBooksData[index].locationCover != null) {
        final fileImage = File(listBooksData[index].locationCover!);
        if (fileImage.existsSync()) {
          fileImage.deleteSync();
        }
      }
      final db = DBHelper();
      if (listBooksData[index].title != null &&
          listBooksData[index].language != null) {
        db.deleteBook(
            listBooksData[index].title!, listBooksData[index].language!);
      }
    }
  }

  openDeleteAlert(
      BuildContext context, List<MapEbookData> listBooksData, int index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Do you want to delete this book?"),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      deleteBook(listBooksData, index);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete book"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    double ratio =
        ((MediaQuery.of(context).orientation == Orientation.portrait))
            ? (MediaQuery.of(context).size.width / 3) /
                ((MediaQuery.of(context).size.height / 3) +
                    (MediaQuery.of(context).size.height) / 36)
            : pow(
                    (MediaQuery.of(context).size.width / 3) /
                        ((MediaQuery.of(context).size.height / 3) +
                            (MediaQuery.of(context).size.height) / 36),
                    -1)
                .toDouble();

    if (listBooks.isEmpty) {
      return const Center(
        child: Text("None book. Add one"),
      );
    } else {
      final listBooksData =
          listBooks.map((e) => MapEbookData.fromJson(e)).toList();
      return SingleChildScrollView(
        child: GridView.builder(
            padding: const EdgeInsets.only(
                right: 9.00, left: 9.00, top: 9.00, bottom: 15.00),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listBooks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 5.0,
                crossAxisCount: 2,
                childAspectRatio: ratio),
            itemBuilder: (BuildContext context, int index) {
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
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Stack(
                            children: [
                              (listBooksData[index].locationCover != null)
                                  ? image.Image.file(
                                      File(listBooksData[index].locationCover!),
                                      fit: BoxFit.fitWidth)
                                  : image.Image.asset(
                                      "assets/nonImageCover.png",
                                      fit: BoxFit.fitWidth),
                              Positioned(
                                right: 0.00,
                                child: Material(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0.6),
                                  child: Tooltip(
                                    message: "Delete book",
                                    child: IconButton(
                                      color: Colors.white,
                                      onPressed: () => openDeleteAlert(
                                          context, listBooksData, index),
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0.00,
                                bottom: 0.00,
                                child: Row(
                                  children: getFlag(context,
                                      [listBooksData[index].language ?? "en"]),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListTile(
                              title: Text(
                                listBooksData[index].title ?? "Untitled",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).primaryColor),
                              ),
                              subtitle: Text(
                                "${((listBooksData[index].author?.isNotEmpty ?? false) && listBooksData[index].author != null) ? listBooksData[index].author : "Anounymous"}",
                                maxLines: 2,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 17),
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      );
    }
  }
}
