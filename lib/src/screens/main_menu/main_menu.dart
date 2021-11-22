import 'dart:convert';
import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_tile.dart';
import 'utils/preview_book.dart';
import 'utils/storage.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<Map> epubList = [];
  void getListBooks() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String>? currentBooks = sharedPreferences.getStringList("books");

    if (currentBooks != null) {
      final bookList = currentBooks.map((e) => json.decode(e) as Map).toList();
      setState(() {
        epubList = bookList;
      });
    }
  }

  changeListBooks(newList) {
    setState(() {
      epubList = newList;
    });
  }

  @override
  void initState() {
    getListBooks();
    super.initState();
  }

  addBook(FilePickerResult? file) async {
    String language = "";
    String title = "";
    String author = "";

    List<PlatformFile>? newBook = file?.files;
    PlatformFile? bookFile = newBook?.first;
    if (bookFile != null) {
      final storageAccess = StorageAccess();
      EpubBookRef? epub;

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // print(title);
                // print(author);
                // print(language);
                if (epub != null) {
                  final mapData = await storageAccess.writeEbook(
                      bookFile, epub!, language, title, author);
                  if (mapData != null) {
                    Map data = json.decode(mapData);
                    setState(() {
                      epubList.add(data);
                    });
                  }
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
          title: const Text("Check all the information"),
          content: FutureBuilder<EpubBookRef>(
              future: storageAccess.getBookRef(bookFile),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || snapshot.data == null) {
                    return Text(snapshot.error.toString());
                  } else {
                    epub = snapshot.data;
                    return PrevieBook(
                      coverImage: snapshot.data!.readCover(),
                      ebook: snapshot.data!,
                      changeAuthor: (String value) {
                        author = value;
                      },
                      changeLanguage: (String value) {
                        language = value;
                      },
                      changeTitle: (String value) {
                        title = value;
                      },
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
      ),
      body: ListBooks(listBooks: epubList, callback: changeListBooks),
      floatingActionButton: Tooltip(
        message: "Add a new book",
        child: FloatingActionButton(
          onPressed: () async {
            final FilePickerResult? result =
                await FilePicker.platform.pickFiles(
                    allowedExtensions: ["epub"],
                    type: FileType.custom,
                    dialogTitle: "Add an ebook",
                    onFileLoading: (status) {
                      return CircularProgressIndicator.adaptive(
                        value: status.index.toDouble(),
                      );
                    });
            if (result != null) {
              addBook(result);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
