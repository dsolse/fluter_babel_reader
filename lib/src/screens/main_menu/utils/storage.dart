import 'dart:convert';
import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:image/image.dart' as cover;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageAccess {
  Future<bool> _requestStorage() async {
    final statusMedia = await Permission.manageExternalStorage.status;
    final statusStorage = await Permission.storage.status;
    if (!statusMedia.isGranted || !statusStorage.isGranted) {
      final resultMedia = await Permission.manageExternalStorage.request();
      final resultStorage = await Permission.storage.request();
      if (resultMedia.isGranted && resultStorage.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<String?> get _storagePath async {
    if (await _requestStorage()) {
      final pathLocation = await getExternalStorageDirectory();
      return pathLocation?.path;
    }
  }

  Future<String?> _writeImage(cover.Image? contentImage, String title) async {
    final String? storageLocation = await _storagePath;
    if (storageLocation != null) {
      final directory =
          Directory(storageLocation.split("/Android/").first + "/Babel");
      final coverImagePath = directory.path + "/coverImage";
      final imageDirectory = Directory(coverImagePath);
      if (!await imageDirectory.exists()) {
        imageDirectory.create();
      }
      if (contentImage != null) {
        final fileImage = File(coverImagePath + "/$title.png");
        fileImage.writeAsBytesSync(cover.encodePng(contentImage));
        return fileImage.path;
      }
    }
  }

  Future<String> _getMapString(String locationBook, String? locationCover,
      String? language, String? author, String? title) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String>? currentBooks = sharedPreferences.getStringList("books");

    final String mapString = json.encode({
      "title": title,
      "author": author,
      "language": language,
      "locationBook": locationBook,
      "locationCover": locationCover
    });
    if (currentBooks == null) {
      await sharedPreferences.setStringList("books", [mapString]);
    } else {
      currentBooks.add(mapString);
      await sharedPreferences.setStringList("books", currentBooks);
    }
    return mapString;
  }

  Future<String?> writeEbook(PlatformFile fileBook) async {
    final String? storageLocation = await _storagePath;
    if (storageLocation != null) {
      final directory =
          Directory(storageLocation.split("/Android/").first + "/Babel");
      if (!await directory.exists()) {
        directory.createSync();
      }
      final ebooksPath = directory.path + "/ebooks";
      final ebooksDirectory = Directory(ebooksPath);
      if (!await ebooksDirectory.exists()) {
        ebooksDirectory.create();
      }
      final epubBook =
          await EpubReader.openBook(File(fileBook.path!).readAsBytesSync());
      final fileEbook = File(ebooksPath + "/" + fileBook.name);
      if (!await fileEbook.exists()) {
        if (fileBook.path != null) {
          File(fileBook.path!).copy(fileEbook.path);
        }
      }

      final pathImage = await _writeImage(
          await epubBook.readCover(), (fileBook.name).replaceAll(" / ", "-"));
      late List<String> lang;
      if (epubBook.Schema?.Package?.Metadata?.Languages != null) {
        lang = epubBook.Schema?.Package?.Metadata?.Languages ?? ["None"];
      } else {
        lang = ["None"];
      }
      final mapData = _getMapString(
          fileEbook.path,
          pathImage,
          ((lang.isNotEmpty) ? lang.first : "None").toString(),
          epubBook.Author,
          epubBook.Title);
      return mapData;
    }
  }
}
