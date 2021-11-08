import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, "books.db");
    // deleteDatabase(path);\

    var theDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE BookLocation(
          IdBookLocation integer primary key autoincrement,
          Title TEXT, 
          LastChapterIndex INTEGER, 
          LastChapterScroll INTEGER,
          Alineo REAL, 
          Language TEXT)
          ''');
        db.execute('''
            CREATE TABLE Words(
          IdWord integer primary key autoincrement,
          Word TEXT, 
          Book INTEGER, 
          Translation TEXT,
          Notes TEXT)
          ''');
      },
    );
    return theDb;
  }

  Future deleteBook(String title, String language) async {
    final Database dbToDelete = await db;
    var response = dbToDelete.delete('BookLocation',
        where: 'Title = ? AND Language = ?', whereArgs: [title, language]);
    return response;
  }

  Future addWord(String word, String translation, String notes, String title,
      String language) async {
    final Database dbToInsert = await db;
    final List<Map> bookData = await dbToInsert.query(
      "BookLocation",
      limit: 1,
      columns: ["IdBookLocation"],
      where: '"Title" = ? AND "Language" = ?',
      whereArgs: [title, language],
    );

    final book = bookData.first;

    dbToInsert.insert(
      "Words",
      {
        'Word': word,
        'Book': book.values.first,
        'Translation': translation,
        'Notes': notes
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map?> getWord(String word) async {
    final Database dbToGet = await db;
    final List<Map> words = await dbToGet.rawQuery(
      'SELECT * FROM Words WHERE "Word" = ?',
      [word],
    );
    if (words.isNotEmpty) {
      return words.first;
    }
  }

  getWords(String title, String language) async {
    final Database dbToGet = await db;

    final List<Map> bookWord = await dbToGet.query(
      "BookLocation",
      columns: ["IdBookLocation"],
      where: '"Title" = ? AND "Language" = ?',
      whereArgs: [title, language],
    );
    List<Map> listWords = [];
    if (bookWord.isNotEmpty) {
      final dataMap = bookWord.first;

      final List<Map> words = await dbToGet.rawQuery(
        "SELECT * FROM Words",
      );

      int val = await dataMap.values.first;

      Iterable<Map> df = words.where((element) => element["Book"] == val);

      for (var value in df) {
        listWords.add(value);
      }
    }

    return listWords;
  }

  Future deleteWords(String title, String word, String language) async {
    final Database dbToGet = await db;

    final List<Map> bookWord = await dbToGet.query(
      "BookLocation",
      columns: ["IdBookLocation"],
      where: '"Title" = ? AND "Language" = ?',
      whereArgs: [title, language],
    );

    if (bookWord.isNotEmpty) {
      final dataMap = bookWord.first;

      await dbToGet.delete(
        'Words',
        where: '"Book" = ? AND "Word" = ?',
        whereArgs: [dataMap["IdBookLocation"], word],
      );
    }
  }

  Future addBook(String title, String language) async {
    final Database dbToInsert = await db;
    var response = dbToInsert.insert(
      'BookLocation',
      {
        'Title': title,
        'LastChapterIndex': 0,
        'LastChapterScroll': 0,
        'Alineo': 0.0,
        'Language': language
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response;
  }

  Future<bool> bookExists(String title, String language) async {
    final Database dbToGet = await db;

    List<Map> contentTitle = await dbToGet.query(
      'BookLocation',
      columns: ['Title', 'Language'],
      where: '"Title" = ? AND "Language" = ?',
      whereArgs: [title, language],
    );
    if (contentTitle.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map> getPosition(String title, String language) async {
    final Database dbToGet = await db;
    List<Map> contentTitle = await dbToGet.query(
      'BookLocation',
      columns: ['LastChapterIndex', 'LastChapterScroll', 'Alineo'],
      where: '"Title" = ? AND "Language" = ?',
      whereArgs: [title, language],
    );
    return contentTitle.first;
  }

  updateLastChapterAlineo(
      double newIndexAlineo, String title, String language) async {
    final Database dbToUpdate = await db;
    dbToUpdate.rawUpdate(
        "UPDATE BookLocation SET Alineo = ? WHERE Title = ? AND Language = ?",
        [newIndexAlineo.toStringAsFixed(3), title, language]);
  }

  updateLastChapterIndex(int newIndex, String title, String language) async {
    final Database dbToUpdate = await db;
    dbToUpdate.rawUpdate(
        "UPDATE BookLocation SET LastChapterIndex = ?, Alineo = ?, LastChapterScroll = ? WHERE Title = ? AND Language = ?",
        [newIndex, 0, 0, title, language]);
  }

  updateLastChapterScroll(
      int newScrollIndex, String title, String language) async {
    final Database dbToUpdate = await db;
    dbToUpdate.rawUpdate(
        "UPDATE BookLocation SET LastChapterScroll = ? WHERE Title = ? AND Language = ?",
        [newScrollIndex, title, language]);
  }
}
