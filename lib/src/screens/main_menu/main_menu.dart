import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:final_babel_reader_app/src/screens/main_menu/utils/preview_book.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_tile.dart';
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
    List<PlatformFile>? newBook = file?.files;
    PlatformFile? bookFile = newBook?.first;
    if (bookFile != null) {
      final storageAccess = StorageAccess();
      final String? mapData = await storageAccess.writeEbook(bookFile);
      if (mapData != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewBook(
                      bookLocation: json.decode(mapData)["locationBook"] ?? '',
                    )));
        Map data = json.decode(mapData);
        setState(() {
          epubList.add(data);
        });
      }
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
